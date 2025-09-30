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
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents, let string = String(data: data, encoding: .utf8) else {
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
