//
//  Controller.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/30/25.
//

import Foundation
import SwiftUI
import HydrogenReporter

@Observable
class BusController: CustomStringConvertible {
    private(set) var canBus: CANBus
    
    private var messages: Binding<[CANMessage]>  

    /// This timer fires the `receiveTimerTick` function, which checks the can bus for messages.
    private var receivingTimer: Timer? = nil
    /// This timer fires the `transmitTimerTick` function, which sends any messages that need to be transmitted.
    private var transmittingTimer: Timer? = nil
    
    var receiveError: CANStatus? = nil
    
    private var runningMessageID: Int = 0
    
    var description: String {
        return "\(canBus.usbBus.displayName) at \(canBus.baudRate.displayName)"
    }
    
    init(with interface: USBBus, baudRate: BaudRate, messages: Binding<[CANMessage]>) throws(CANStatus) {
        self.canBus = try CANBus(usbBus: interface, baudRate: baudRate)
        self.messages = messages
    }
    
    func initTimers() {
        LOG("Initializing Timers...", level: .working)
        invalidateTimers()
        receivingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { self.receiveTimerTick($0) })
        transmittingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: {  self.transmitTimerTick($0) })
        LOG("Timers Initialized", level: .success)
    }

    func invalidateTimers() {
        LOG("Invalidating Timers...", level: .working)
        receivingTimer?.invalidate()
        transmittingTimer?.invalidate()
        LOG("Timers Invalidated", level: .success)
    }
    
    private func receiveTimerTick(_ timer: Timer) {
        var message: TPCANMsg = .init()
        var timestamp: TPCANTimestamp = .init()

        let startingPoint: Date = .now
        
        LOG("Received message...", level: .working)
        while (startingPoint.timeIntervalSinceNow > -0.01) {
            let rawStatus = CAN_Read(UInt16(canBus.usbBus.rawValue), &message, &timestamp)
            
            // Convert to an error code and make sure it is okay
            guard let status = CANStatus(rawValue: rawStatus) else {
                LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
                return
            }

            // Only proceed if the receive queue is not empty.
            guard status != .qrcvempty else {
                return
            }
            
            guard !status.isFatal else {
                invalidateTimers()
                receiveError = status
                return
            }

            guard status == .ok else {
                LOG("PCAN Status Code: \(status)", level: .error)
                receiveError = status
                continue
            }
            
            let canMessage = CANMessage(id: runningMessageID, message: message, timestamp: timestamp)
            messages.wrappedValue.append(canMessage)

            runningMessageID += 1
        }
    }
        
    private func transmitTimerTick(_ timer: Timer) {
//        for index in 0..<transmittingMessages.count {
//            do {
//                try transmittingMessages[index].transmit(bus: bus)
//            } catch {
//                LOG("Transmitting Error", error, level: .error)
//                if let error = error as? CANStatus {
//                    receivedError = error
//                }
//                continue
//            }
//        }
    }
}
