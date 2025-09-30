//
//  Connections.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import SwiftUI
import HydrogenReporter

struct Connections: View {
    @Environment(\.openDocument) var openDocument
    @Environment(\.newDocument) var newDocument
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var presentConnectSheet: Bool = false
    @State var presentFileImporter: Bool = false
    
    var body: some View {
        VStack {
            Button {
                newDocument(contentType: .json)
                dismissWindow()
            } label: {
                Label("Create a new CAN Document", symbol: .doc)
            }
            Button {
                presentFileImporter.toggle()
            } label: {
                Label("Load a CAN Dump", symbol: .arrow_down_doc)
            }
        }
        .fileImporter(isPresented: $presentFileImporter, allowedContentTypes: [.json]) { completion in
            do {
                let result = try completion.get()
                guard result.startAccessingSecurityScopedResource() else {
                    LOG("Failed to access security scoped resource", level: .error)
                    return
                }
                
                Task {
                    do {
                        try await openDocument(at: result)
                        dismissWindow()
                    } catch {
                        LOG(error.localizedDescription, level: .error)
                    }
                }
            } catch  {
                LOG(error.localizedDescription, level: .error)
            }
        }
        .sheet(isPresented: $presentConnectSheet) {
            ConnectSheet { interface, baudRate in
                do {
                    let bus = try CANBus(bus: interface, baudRate: baudRate)
                    
                } catch {
                    
                }
            }
        }
    }
}
