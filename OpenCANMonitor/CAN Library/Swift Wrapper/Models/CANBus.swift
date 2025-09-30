//
//  CANBus.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import Foundation
import HydrogenReporter

class CANBus {
    var bus: USBBus
    var baudRate: BaudRate

    init(bus: USBBus, baudRate: BaudRate) throws (CANStatus) {
        LOG("Creating CAN bus: \(bus)...", level: .working)
        
        self.bus = bus
        self.baudRate = baudRate
        
        let rawStatus = CAN_Initialize(UInt16(bus.rawValue), UInt16(baudRate.rawValue), 0, 0, 0)

        let status = try validateCANStatus(rawStatus: rawStatus)
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(bus) at baud rate \(baudRate)", level: .success)
    }

    @discardableResult
    private func validateCANStatus(rawStatus: UInt32) throws (CANStatus) -> CANStatus {
        // Convert to a swift status code
        guard let status = CANStatus(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw CANStatus.unknown
        }
        
        // Make sure we got an OK status code
        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        return status
    }
    
    deinit {
        LOG("Uninitialize the CAN connection...", level: .working)
        let rawStatus = CAN_Uninitialize(UInt16(bus.rawValue))

        do {
            let status = try validateCANStatus(rawStatus: rawStatus)
            LOG("Uninitialize CAN State: \(status)", level: .success)

        } catch {
            LOG("Failed to Uninitialize CAN State: \(error)", level: .error)
        }
    }
}
