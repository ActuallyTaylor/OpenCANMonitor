//
//  DocumentView.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import HydrogenReporter
import SwiftUI

struct DocumentControllerView: View {
    var documentURL: URL?
    @State var document: CANDocumentJSON
    @State var controller: BusController? = nil
    
    @State var selectedTool: Tool = .bus
    
    // Alerts
    @State var presentConnectionSheet: Bool = false
    @State var showCanError: Bool = false
    @State var canError: CANStatus? = nil

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTool) {
                ForEach(Tool.allCases) { tool in
                    NavigationLink(value: tool) {
                        Label(tool.displayName, symbol: tool.image)
                    }
                }
            }
        } detail: {
            Group {
                switch selectedTool {
                case .bus:
                    BusView(documentURL: documentURL, document: $document, controller: $controller)
                case .transmit:
                    TransmitView2()
                }
            }
            .toolbar {
                ToolbarItem(id: "connect") {
                    if let controller {
                        Text("Connected to \(controller.description)")
                    } else {
                        Button {
                            presentConnectionSheet.toggle()
                        } label: {
                            Text("Connect to CAN Dongle")
                        }
                    }
                }
            }
        }
        .onAppear {
            if let documentURL {
                RecentController.addRecent(url: documentURL)
            }
    
            if let interface = document.openInterface, let baudRate = document.openBaudRate {
                do {
                    controller = try BusController(with: interface, baudRate: baudRate, messages: $document.messages)
                    document.openInterface = nil
                    document.openBaudRate = nil
                } catch let error as CANStatus {
                    canError = error
                    showCanError = true
                } catch {
                    LOG("An Unexpected Error Occurred: \(error)", level: .error)
                }
            }
        }
        .alert(isPresented: $showCanError, error: canError) {
            Button("Close") { }
        }
        .sheet(isPresented: $presentConnectionSheet) {
            ConnectSheet { interface, baudRate in
                do {
                    controller = try BusController(with: interface, baudRate: baudRate, messages: $document.messages)
                } catch let error as CANStatus {
                    canError = error
                    showCanError = true
                } catch {
                    LOG("An Unexpected Error Occurred: \(error)", level: .error)
                }
            }
        }
    }
}
