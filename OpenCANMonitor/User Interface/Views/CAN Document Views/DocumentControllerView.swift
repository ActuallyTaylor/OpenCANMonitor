//
//  DocumentView.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import HydrogenReporter
import SwiftUI
import SwiftData

struct DocumentControllerView: View {
    @Query var transmitMessages: [CANTransmitMessage]

    var documentURL: URL?
    @State var document: JSONCANDocument
    @State var controller: BusController? = nil
    
    @State var selectedTool: Tool = .bus
    
    // Alerts
    @State var presentConnectionSheet: Bool = false
    @State var showCanError: Bool = false
    @State var canError: CANStatus? = nil

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailViews
        }
        .onAppear {    
            if let interface = document.openInterface, let baudRate = document.openBaudRate {
                do {
                    controller = try BusController(with: interface, baudRate: baudRate, messages: $document.messages)
                    document.openInterface = nil
                    document.openBaudRate = nil
                    
                    controller?.initTimers()
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
        .alert(error: Binding(
            get: { controller?.receiveError },
            set: { newValue in controller?.receiveError = newValue }
        )) {
            Button("Close") { }
        }
        .sheet(isPresented: $presentConnectionSheet) {
            ConnectSheet { interface, baudRate in
                do {
                    // Disable any existing controllers
                    if let controller {
                        controller.invalidateTimers()
                        self.controller = nil
                    }
                    
                    controller = try BusController(with: interface, baudRate: baudRate, messages: $document.messages)
                    controller?.initTimers()
                } catch let error as CANStatus {
                    canError = error
                    showCanError = true
                } catch {
                    LOG("An Unexpected Error Occurred: \(error)", level: .error)
                }
            }
        }
        .onChange(of: controller?.receiveError) { _, newValue in
            if let newValue {
                if newValue.isFatal {
                    controller = nil
                }
            }
        }
    }
    
    var sidebar: some View {
        List(selection: $selectedTool) {
            ForEach(Tool.allCases) { tool in
                NavigationLink(value: tool) {
                    Label(tool.displayName, symbol: tool.image)
                        .badge(tool == .transmit ? transmitMessages.filter(\.currentlyTransmitting).count : 0)
                }
            }
        }
    }
    
    var detailViews: some View {
        Group {
            switch selectedTool {
            case .bus:
                BusView(document: $document, controller: $controller)
            case .transmit:
                TransmitView(document: $document, controller: $controller)
            }
        }
        .toolbar {
            ToolbarItem(id: "connect") {
                Button {
                    presentConnectionSheet.toggle()
                } label: {
                    if let controller {
                        Text("Connected to \(controller.description)")
                    } else {
                        Text("Connect to CAN Dongle")
                    }
                }

            }
        }
    }
}
