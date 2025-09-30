//
//  CANTransmitMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import Foundation
import HydrogenReporter

/// A message that will be transmitted across the CAN network.
struct CANTransmitMessage: Identifiable, Equatable, Hashable, Codable {
    /// A UUID representing the message.
    var id: UUID = UUID()
    /// The device CAN ID that the message should be sent from.
    let deviceID: UInt32
    /// The type of the transmit message. See ``PCANMessageType``.
    let type: CANMessageType
    /// The data that is included within the message.
    let data: MessageData
    /// The length of the data.
    let length: Int
    /// How many cycles (milliseconds) it should take between sending the message
    let cycleTime: Int
    /// The last `TimeInterval` that the message was transmitted at.
    var lastTransmitted: TimeInterval = 0
    /// Should the message currently be transmitting?
    var currentlyTransmitting: Bool
    
    /// An initializer that takes in all of the parameters one at a time
    /// - Parameters:
    ///   - id: An optional parameter for the message ID.
    ///   - deviceID: The CAN device ID  for the transmit message.
    ///   - type: The type of the transmit message.
    ///   - data: The data of the transmit message.
    ///   - length: The length of the `data`.
    ///   - cycleTime: How many milliseconds between transmit cycles.
    ///   - currentlyTransmitting: Should the message be currently transmitting?
    init(id: UUID = UUID(), deviceID: UInt32, type: CANMessageType, data: MessageData, length: Int, cycleTime: Int, currentlyTransmitting: Bool) {
        self.id = id
        self.deviceID = deviceID
        self.type = type
        self.data = data
        self.length = length
        self.cycleTime = cycleTime
        self.currentlyTransmitting = currentlyTransmitting
    }
    
    /// A blank initializer for a CAN Transmit Message that should only be used as a fallback.
    /// This was implemented to satisfy the Swift subscript protocol.
    init() {
        self.deviceID = 0
        self.type = .errFrame
        self.data = .init(byte0: 0, byte1: 0, byte2: 0, byte3: 0, byte4: 0, byte5: 0, byte6: 0, byte7: 0)
        self.cycleTime = 0
        self.length = 0
        self.currentlyTransmitting = false
    }
    
    /// A function that transmits this message over a given ``PCANUSBBus``.
    /// This function does not contain many log statements because we do not want to flood the logger bus.
    /// - Parameter bus: The ``PCANUSBBus`` to transmit over.
    mutating func transmit(bus: USBBus) throws {
        guard currentlyTransmitting else { return }
        guard ((Date.now.timeIntervalSince1970 - lastTransmitted) * 1000) > Double(cycleTime) else { return }

        var message: TPCANMsg = .init(ID: deviceID, MSGTYPE: UInt8(type.rawValue), LEN: UInt8(length), DATA: data.tuple)
        
        let rawStatus = CAN_Write(UInt16(bus.rawValue), &message)
        guard let status = CANStatus(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw CanChannelMonitor.MonitorError.invalidError
        }

        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        lastTransmitted = Date.now.timeIntervalSince1970
    }
    
    /// Basic conformance to the hashable protocol.
    /// - Parameter hasher: the `Hasher` to hash into
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.currentlyTransmitting)
        hasher.combine(self.cycleTime)
        hasher.combine(self.deviceID)
        hasher.combine(self.lastTransmitted)
        hasher.combine(self.length)
        hasher.combine(self.type)
    }
}
