//
//  CANBus.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import Foundation
import HydrogenReporter

final class CANBus {
    private(set) var usbBus: USBBus
    private(set) var baudRate: BaudRate

    init(usbBus: USBBus, baudRate: BaudRate) throws (CANStatus) {
        LOG("Creating CAN bus: \(usbBus)...", level: .working)
        
        self.usbBus = usbBus
        self.baudRate = baudRate
        
        let rawStatus = CAN_Initialize(UInt16(usbBus.rawValue), UInt16(baudRate.rawValue), 0, 0, 0)

        let status = try validateCANStatus(rawStatus: rawStatus)
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(usbBus) at baud rate \(baudRate)", level: .success)
    }
    
    deinit {
        LOG("Uninitialize the CAN connection...", level: .working)
        let rawStatus = CAN_Uninitialize(UInt16(usbBus.rawValue))

        do {
            let status = try validateCANStatus(rawStatus: rawStatus)
            LOG("Uninitialize CAN State: \(status)", level: .success)

        } catch {
            LOG("Failed to Uninitialize CAN State: \(error)", level: .error)
        }
    }
}

extension CANBus {
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
}
