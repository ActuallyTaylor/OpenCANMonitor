//
//  CANDocument.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import SwiftUI
import UniformTypeIdentifiers
import HydrogenReporter

struct CANDocumentJSON: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    
    struct Format: Codable {
        var messages: [CANMessage]
        var transmittingMessages: [CANTransmitMessage]
    }
    
    var messages: [CANMessage]
    var transmittingMessages: [CANTransmitMessage]
    
    /// Store information about the interface that should be connected to when the document is opened.
    var openInterface: USBBus? = nil
    /// Store information about the baud rate that should be used when the document is opened.
    var openBaudRate: BaudRate? = nil
    
    init() {
        self.messages = []
        self.transmittingMessages = []
    }
    
    init(interface: USBBus, baudRate: BaudRate) {
        self.init()
        self.openInterface = interface
        self.openBaudRate = baudRate
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let format = try JSONDecoder().decode(Format.self, from: data)
        self.messages = format.messages
        self.transmittingMessages = format.transmittingMessages
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let jsonData = try JSONEncoder().encode(messages)
        return FileWrapper(regularFileWithContents: jsonData)
    }
}
