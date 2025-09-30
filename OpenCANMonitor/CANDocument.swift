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
    var messages: [CANMessage]
    
    /// Store information about the interface that should be connected to when the document is opened.
    var openInterface: USBBus? = nil
    /// Store information about the baud rate that should be used when the document is opened.
    var openBaudRate: BaudRate? = nil
    
    init() {
        self.messages = []
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
                
        let decoder = JSONDecoder()
        messages = try decoder.decode([CANMessage].self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        
        let jsonData = try encoder.encode(messages)
        return FileWrapper(regularFileWithContents: jsonData)
    }
}
