//
//  TransmitView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct TransmitView: View {
    @EnvironmentObject var channelMonitor: CanChannelMonitor
    @State var selectedMessages: Set<CANTransmitMessage.ID> = .init()

    let maxInspectorWidth: CGFloat = 400
    
    @AppStorage("inspectorWidth") var inspectorWidth: Double = 200
    @AppStorage("inspectorCollapsed") var inspectorCollapsed: Bool = true
    
    @State var presentCreateMessageView: Bool = false
    @State var lastLocations: [CGPoint] = []
    let maxLastLocations = 10

    var body: some View {
        HStack(spacing: 0) {
            ScrollViewReader { reader in
//                Table(channelMonitor.transmittingMessages, selection: $selectedMessages) {
//                    TableColumn("Number", value: \.id.description)
//                        .width(min: 5, ideal: 25)
//                    TableColumn("Device ID") { message in
//                        Text(message.deviceID.hex(length: 3))
//                    }
//                    .width(min: 5, ideal: 25)
//                    TableColumn("Type", value: \.type.displayName)
//                        .width(min: 5, ideal: 50)
//                    TableColumn("Hex Data", value: \.data.description)
//                    TableColumn("ASCII Data", value: \.data.ascii)
//                    TableColumn("Decimal Data", value: \.data.decimal)
//                    TableColumn("Active", value: \.currentlyTransmitting) { message in
//                        Toggle("Active", isOn: message.currentlyTransmitting)
//                            .labelsHidden()
//                    }
//                }
//                .tableStyle(.inset)
//                .onChange(of: channelMonitor.messages) { newValue in
//                    reader.scrollTo(newValue.last?.id)
//                }
            }
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
                .opacity(inspectorCollapsed ? 0 : 1)
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
        .toolbar {
            ToolbarItem(id: "addItem") {
                Button {
                    presentCreateMessageView.toggle()
                } label: {
                    Label("Add Message", symbol: .plus)
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
        .sheet(isPresented: $presentCreateMessageView) {
            CreateMessageView()
        }
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

struct TransmitView_Previews: PreviewProvider {
    static var previews: some View {
        TransmitView()
    }
}
