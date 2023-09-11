//
//  ContentView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/4/23.
//

import SwiftUI
import SFSymbols
import HydrogenReporter

struct ReceivingTableView: View {
    @EnvironmentObject var channelMonitor: CanChannelMonitor
    
    @State var presentAddMessage: Bool = false
    @State var presentFilter: Bool = false
    @State var presentError: Bool = false
    
    @State var canError: PCANError? = nil
    
    @State var hexDataFilter: String = ""
    @State var asciiDataFilter: String = ""
    @State var messageType: FilterType = .all
    
    @State var selectedMessages: Set<CANMessage.ID> = .init()
    
    let maxInspectorWidth: CGFloat = 400
    
    @AppStorage("inspectorWidth") var inspectorWidth: Double = 200
    @AppStorage("inspectorCollapsed") var inspectorCollapsed: Bool = true
    
    @State var lastLocations: [CGPoint] = []
    let maxLastLocations = 10
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollViewReader { reader in
                Table(channelMonitor.messages, selection: $selectedMessages) {
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
                .onChange(of: channelMonitor.messages) { newValue in
                    reader.scrollTo(newValue.last?.id)
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
            }
            
            VStack {
                if let selectedMessage = channelMonitor.messages.first(where: { message in
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
        .navigationTitle("Receiving Messages")
        .toolbar(id: "options") {
            ToolbarItem(id: "clear") {
                Button {
                    channelMonitor.clearMessages()
                } label: {
                    Label("Clear", symbol: .clear)
                }
            }
            ToolbarItem(id: "saveOrLoad") {
                Menu {
                    Button {
                        do {
                            try channelMonitor.save()
                        } catch {
                            print("Serialization Error \(error)")
                        }
                    } label: {
                        Label("Save CAN Messages", symbol: .opticaldisc)
                    }
                    Button {
                        do {
                            try channelMonitor.load()
                        } catch {
                            print("Serialization Error \(error)")
                        }
                    } label: {
                        Label("Load CAN Messages", symbol: .arrow_down_doc)
                    }

                } label: {
                    Label("File Operations", symbol: .arrow_up_arrow_down)
                }

            }
            ToolbarItem(id: "sidebar") {
                Button {
                    toggleSidebar()
                } label: {
                    Label("Toggle Sidebar", symbol: .sidebar_right)
                }
            }
        }
        .alert(isPresented: $presentError, error: canError, actions: { error in
            Button("Okay", role: .cancel) { }
        }, message: { error in
            Text("There was an error originating from the CAN Driver. Please double check that you are plugged into a CAN Dongle. If you are, try re-plugging.")
        })
    }
    
    private func toggleSidebar() {
        withAnimation {
            inspectorCollapsed.toggle()
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

struct ReceivingTableView_Previews: PreviewProvider {
    static var previews: some View {
        ReceivingTableView()
    }
}
