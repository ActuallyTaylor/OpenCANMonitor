//
//  DocumentView.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import HydrogenReporter
import SwiftUI

struct DocumentView: View {
    @State var document: CANDocumentJSON
    
    @State var controller: DocumentController = DocumentController()
    
    // Select Messages
    @State var selectedMessages: Set<CANMessage.ID> = .init()

    // Sidebar
    @State var lastLocations: [CGPoint] = []
    let maxLastLocations = 10
    let maxInspectorWidth: CGFloat = 400
    
    @AppStorage("inspectorWidth") var inspectorWidth: Double = 200
    @AppStorage("inspectorCollapsed") var inspectorCollapsed: Bool = true
    
    // CAN Connection
    @State var presentConnectionSheet: Bool = false
    
    @State var showCanError: Bool = false
    @State var canError: CANStatus? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationStack {
                ScrollViewReader { reader in
                    Table(document.messages, selection: $selectedMessages) {
                        TableColumn("Number", value: \.id.description)
                            .width(min: 5, ideal: 25)
                        TableColumn("Time", value: \.timestamp)
                        TableColumn("Device ID") { message in
                            Text(message.deviceID.hex(length: 3))
                        }
                        .width(min: 5, ideal: 25)
                        TableColumn("Type", value: \.type.displayName)
                            .width(min: 5, ideal: 50)
                        TableColumn("Hex Data", value: \.data.description)
                        TableColumn("ASCII Data", value: \.data.ascii)
                        TableColumn("Decimal Data", value: \.data.decimal)
                    }
                    .tableStyle(.inset)
                    .onChange(of: document.messages) { _, newValue in
                        reader.scrollTo(newValue.last?.id)
                    }
                }
            }

            if !inspectorCollapsed {
                Divider()
                    .frame(width: 5)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            guard !detectDragLoop(value: value) else { return }
                            inspectorWidth = (inspectorWidth - value.translation.width).clamped(to: (0...maxInspectorWidth))
                        }
                    )
                
                VStack {
                    if let selectedMessage = document.messages.first(where: { message in
                        return message.id == selectedMessages.first
                    }) {
                        ScrollView {
                            MessageDetail(message: selectedMessage)
                        }
                    } else {
                        Text("No Currently Selected Message")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .frame(width: inspectorCollapsed ? 0 : inspectorWidth)
            }
        }
        .animation(.default, value: inspectorCollapsed)
        .toolbar {
            ToolbarItem(id: "connect") {
                if let bus = controller.bus {
                    Text("Connected to \(bus.bus.displayName)")
                } else {
                    Button {
                        presentConnectionSheet.toggle()
                    } label: {
                        Text("Connect to CAN Dongle")
                    }
                }
            }
            ToolbarItem(id: "clear") {
                Button {

                } label: {
                    Label("Clear", symbol: .clear)
                }
            }
            ToolbarItem(id: "sidebar") {
                Button {
                    inspectorCollapsed.toggle()
                } label: {
                    Label("Toggle Sidebar", symbol: .sidebar_right)
                }
            }
        }
        .sheet(isPresented: $presentConnectionSheet) {
            ConnectSheet { interface, baudRate in
                do {
                    try controller.connect(to: interface, baudRate: baudRate)
                } catch let error as CANStatus {
                    canError = error
                    showCanError = true
                } catch {
                    LOG("An Unexpected Error Occurred: \(error)", level: .error)
                }
            }
        }
        .alert(isPresented: $showCanError, error: canError) { 
            Button("Cancel") { }
        }
    }
    
    private func detectDragLoop(value: DragGesture.Value) -> Bool {
        lastLocations.append(value.location)
        if lastLocations.count > maxLastLocations {
            lastLocations = Array(lastLocations.dropFirst())
        }

        let set = NSCountedSet(array: lastLocations)
        return set.count(for: value.location) > 2
    }
}
