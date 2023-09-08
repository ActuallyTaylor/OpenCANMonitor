//
//  Monitor.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation
import AppKit
import HydrogenReporter

class CanChannelMonitor: ObservableObject {
    enum CanChannelMonitorError: Error {
        case invalidError
        case invalidJSON
    }
    
    @Published var messages: [CANMessage] = []
    @Published var transmittingMessages: [CANTransmitMessage] = []
    @Published var receivedError: PCANError? = nil
    @Published var initialized: Bool = false
    @Published var initializedViews: [NavigableView] = [.connections]
    
    var runningCounter: Int = 0
    var timer: Timer?
    var bus: PCANUSBBus
    var baudRate: PCANBaudRate
    
    init() {
        self.bus = .none
        self.baudRate = .none
        initialized = false
    }
    
    deinit {
        timer?.invalidate()
    }

    func initialize(bus: PCANUSBBus, baudRate: PCANBaudRate) throws {
        if self.bus != .none || self.baudRate != .none {
            try? self.uninitialize()
        }
        
        self.bus = bus
        self.baudRate = baudRate
        
        // MARK: Connect to the CAN Bus
        let rawStatus = CAN_Initialize(UInt16(bus.rawValue), UInt16(baudRate.rawValue), 0, 0, 0)

        // Convert to an error code and make sure it is okay
        guard let status = PCANError(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw CanChannelMonitorError.invalidError
        }
        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(bus) at baud rate \(baudRate)", level: .success)
        
        initialized = true
        initializedViews = [.connections, .receiving, .transmitting]
        initTimer()
    }
    
    func uninitialize() throws {
        // MARK: Connect to the CAN Bus
        let rawStatus = CAN_Uninitialize(UInt16(bus.rawValue))

        // Convert to an error code and make sure it is okay
        guard let status = PCANError(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw CanChannelMonitorError.invalidError
        }
        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(bus) at baud rate \(baudRate)", level: .success)

        initialized = false
        initializedViews = [.connections]
        self.bus = .none
        self.baudRate = .none
    }
    
    func clearMessages() {
        self.runningCounter = 0
        self.messages.removeAll()
    }
        
    private func initTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { self.receiveTimerTick($0) })
    }
    
    private func receiveTimerTick(_ timer: Timer) {
        var message: TPCANMsg = .init()
        var timestamp: TPCANTimestamp = .init()

        let startingPoint: Date = .now
        
        while (startingPoint.timeIntervalSinceNow > -0.01) {
            let rawStatus = CAN_Read(UInt16(bus.rawValue), &message, &timestamp)
            // Convert to an error code and make sure it is okay
            guard let status = PCANError(rawValue: rawStatus) else {
                LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
                return
            }

            guard status == .ok else {
//                LOG("PCAN Status Code: \(status)", level: .error)
//                receivedError = status
                continue
            }

            let canMessage = CANMessage(id: runningCounter, message: message, timestamp: timestamp)
            messages.append(canMessage)

            runningCounter += 1
        }
    }
}

extension CanChannelMonitor {
    func load() throws {
        guard let url = showOpenPanel() else {
            return
        }
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        self.messages = try decoder.decode([CANMessage].self, from: data)
        initializedViews = [.connections, .receiving]
    }
    
    func save() throws {
        guard let url = showSavePanel() else {
            return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(messages)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw CanChannelMonitorError.invalidJSON
        }
        try jsonString.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save CAN Message Log"
        savePanel.message = "Choose a folder and a name to store the message log."
        savePanel.nameFieldLabel = "CAN Message Log Name:"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.title = "Choose CAN Message Log"
        openPanel.message = "Choose a CAN Message Log to load into CANMonitor"
        
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }

}
