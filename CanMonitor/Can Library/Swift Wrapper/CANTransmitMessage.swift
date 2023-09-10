//
//  CANTransmitMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import Foundation
import HydrogenReporter

struct CANTransmitMessage: Identifiable, Equatable, Hashable, Codable {
    var id: UUID = UUID()
    let deviceID: UInt32
    let type: PCANMessageType
    let data: CANMessage.MessageData
    let length: Int
    let cycleTime: Int
    var lastTransmitted: TimeInterval = 0
    var currentlyTransmitting: Bool
    
    init(deviceID: UInt32, type: PCANMessageType, data: CANMessage.MessageData, length: Int, cycleTime: Int, currentlyTransmitting: Bool) {
        self.deviceID = deviceID
        self.type = type
        self.data = data
        self.length = length
        self.cycleTime = cycleTime
        self.currentlyTransmitting = currentlyTransmitting
    }
    
    init() {
        self.deviceID = 0
        self.type = .errFrame
        self.data = .init(byte0: 0, byte1: 0, byte2: 0, byte3: 0, byte4: 0, byte5: 0, byte6: 0, byte7: 0)
        self.cycleTime = 0
        self.length = 0
        self.currentlyTransmitting = false
    }
    
    mutating func transmit(bus: PCANUSBBus) throws {
        guard currentlyTransmitting else { return }
        guard ((Date.now.timeIntervalSince1970 - lastTransmitted) * 1000) > Double(cycleTime) else {
            print("not Transmitting \(id) \((Date.now.timeIntervalSince1970 - lastTransmitted) * 1000) \(Date.now.timeIntervalSince1970) \(lastTransmitted)")
            return
        }

        var message: TPCANMsg = .init(ID: deviceID, MSGTYPE: UInt8(type.rawValue), LEN: UInt8(length), DATA: data.tuple)
        
        let rawStatus = CAN_Write(UInt16(bus.rawValue), &message)
        guard let status = PCANError(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw CanChannelMonitor.CanChannelMonitorError.invalidError
        }

        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        lastTransmitted = Date.now.timeIntervalSince1970
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
}
