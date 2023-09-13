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
    enum MonitorError: LocalizedError {
        case invalidError
        case invalidJSON
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidError:
                return "PCANUSB returned an invalid error code."
            case .invalidJSON:
                return "JSON encoding failed."
            case .invalidURL:
                return "The provided URL is not valid."
            }
        }
    }
    
    @Published var messages: [CANMessage] = []
    @Published var transmittingMessages: [CANTransmitMessage] = []
    @Published var receivedError: CANStatus? = nil
    @Published var initialized: Bool = false
    @Published var initializedViews: [NavigableView] = [.connections]
    
    var runningCounter: Int = 0
    var receivingTimer: Timer?
    var transmittingTimer: Timer?

    var bus: USBBus
    var baudRate: BaudRate
    
    var lastBus: USBBus = .none
    var lastBaud: BaudRate = .none
    var hasInitializedOnce: Bool = false
    
    init() {
        self.bus = .none
        self.baudRate = .none
        initialized = false
        
        try? loadSavedTransmittingMessages()
    }
    
    deinit {
        invalidateTimers()
    }
    
    func initialize(bus: USBBus, baudRate: BaudRate) throws {
        LOG("Initializing the CAN connection...", level: .working)
        if self.bus != .none || self.baudRate != .none {
            LOG("A previous connection was not uninitialized, uninitializing it now...", level: .working)
            try? self.uninitialize()
        }
        
        self.bus = bus
        self.baudRate = baudRate
        
        let rawStatus = CAN_Initialize(UInt16(bus.rawValue), UInt16(baudRate.rawValue), 0, 0, 0)

        // Convert to an status code
        guard let status = CANStatus(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw MonitorError.invalidError
        }
        // Make sure we got an OK status code
        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
                
        initialized = true
        hasInitializedOnce = true
        initializedViews = NavigableView.allCases
        initTimers()
        
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(bus) at baud rate \(baudRate)", level: .success)
    }
    
    func reInitialize() throws {
        // We want to silently (almost) fail if we are already initialized or we have yet to initialize.
        guard hasInitializedOnce else {
            LOG("Has not initialized once, not reinitializing.")
            return
        }
        guard !initialized else {
            LOG("Already Initialized, not resetting-up connection to CAN.")
            return
        }
        
        // If either last bus or last baud are .none, we should not reinitialize.
        guard self.lastBus != .none && self.lastBaud != .none else {
            LOG("Not reinitializing because lastBaud or lastBus haven one value.")
            return
        }
        
        try initialize(bus: self.lastBus, baudRate: self.lastBaud)
    }
    
    func uninitialize() throws {
        LOG("Unitializing the CAN connection...", level: .working)
        let rawStatus = CAN_Uninitialize(UInt16(bus.rawValue))

        // Convert to a swift status code
        guard let status = CANStatus(rawValue: rawStatus) else {
            LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
            throw MonitorError.invalidError
        }
        // Make sure we got an OK status code
        guard status == .ok else {
            LOG("PCAN Status Code: \(status)", level: .error)
            throw status
        }
        
        initialized = false
        initializedViews = [.connections]
        
        self.lastBus = bus
        self.lastBaud = baudRate
        
        self.bus = .none
        self.baudRate = .none
        
        // We do not set bus and baud rate to none because we may end up reInitializing
        LOG("Initialized CAN State: \(status)", level: .success)
        LOG("Connected to Bus: \(bus) at baud rate \(baudRate)", level: .success)
    }
    
    func invalidateTimers() {
        LOG("Invalidating Timers...", level: .working)
        receivingTimer?.invalidate()
        transmittingTimer?.invalidate()
        LOG("Timers Invalidated", level: .success)
    }
    
    func initTimers() {
        guard initialized else { return }
        LOG("Initializing Timers...", level: .working)
        invalidateTimers()
        receivingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { self.receiveTimerTick($0) })
        transmittingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: {  self.transmitTimerTick($0) })
        LOG("Timers Initialized", level: .success)
    }

    func clearMessages() {
        LOG("Clearing Messages...", level: .working)
        self.runningCounter = 0
        self.messages.removeAll()
        LOG("Messages Cleared", level: .success)
    }
        
    private func receiveTimerTick(_ timer: Timer) {
        var message: TPCANMsg = .init()
        var timestamp: TPCANTimestamp = .init()

        let startingPoint: Date = .now
        
        while (startingPoint.timeIntervalSinceNow > -0.01) {
            let rawStatus = CAN_Read(UInt16(bus.rawValue), &message, &timestamp)
            // Convert to an error code and make sure it is okay
            guard let status = CANStatus(rawValue: rawStatus) else {
                LOG("Unable to convert PCAN Status Code: 0x\(rawStatus)", level: .error)
                return
            }

            guard status != .qrcvempty else {
                return
            }
            
            guard status == .ok else {
                LOG("PCAN Status Code: \(status)", level: .error)
                receivedError = status
                continue
            }

            let canMessage = CANMessage(id: runningCounter, message: message, timestamp: timestamp)
            messages.append(canMessage)

            runningCounter += 1
        }
    }
        
    private func transmitTimerTick(_ timer: Timer) {
        for index in 0..<transmittingMessages.count {
            do {
                try transmittingMessages[index].transmit(bus: bus)
            } catch {
                LOG("Transmitting Error", error, level: .error)
                if let error = error as? CANStatus {
                    receivedError = error
                }
                continue
            }
        }
    }
}

// MARK: User facing save functions
extension CanChannelMonitor {
    func load() throws {
        LOG("Loading CAN Dump from URL...", level: .working)
        guard let url = showOpenPanel() else {
            throw MonitorError.invalidURL
        }
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        self.messages = try decoder.decode([CANMessage].self, from: data)
        initializedViews = [.connections, .receiving]
        LOG("Loaded CAN Dump from URL \(url)", level: .success)
    }
    
    func save() throws {
        LOG("Saving CAN Dump to file...", level: .working)
        guard let url = showSavePanel() else {
            return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(messages)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw MonitorError.invalidJSON
        }
        try jsonString.write(to: url, atomically: true, encoding: .utf8)
        LOG("Saved CAN Dump to file \(url)...", level: .working)
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

extension CanChannelMonitor {
    subscript(transmitID: CANTransmitMessage.ID?) -> CANTransmitMessage {
        get {
            if let id = transmitID {
                return transmittingMessages.first(where: { $0.id == id })!
            }
            return CANTransmitMessage()
        }

        set(newValue) {
            if let index = transmittingMessages.firstIndex(where: { $0.id == newValue.id }) {
                transmittingMessages[index] = newValue
            } else {
                print("Unable to get index \(newValue)")
            }
        }
    }
}

extension CanChannelMonitor {
    private func loadSavedTransmittingMessages() throws {
        LOG("Loading Saved Transmit Messages...", level: .working)
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        url.append(path: "transmitMessages.json")
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        self.transmittingMessages = try decoder.decode([CANTransmitMessage].self, from: data)
        LOG("Loaded Saved Transmit Messages", level: .success)
    }
    
    func saveTransmittingMessages() throws {
        LOG("Saving transmit messages...", level: .working)
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        url.append(path: "transmitMessages.json")

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(transmittingMessages)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw MonitorError.invalidJSON
        }
        try jsonString.write(to: url, atomically: true, encoding: .utf8)
        LOG("Loaded transmit messages...", level: .success)
    }
}
