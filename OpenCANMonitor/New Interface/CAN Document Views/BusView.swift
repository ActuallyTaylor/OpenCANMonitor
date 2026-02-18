//
//  BusView.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 10/1/25.
//

import SwiftUI
import HydrogenReporter

struct BusView: View {
    @Environment(\.scenePhase) var scenePhase: ScenePhase

    @Binding var document: CANDocumentJSON
    @Binding var controller: BusController?

    // Select Messages
    @State var selectedMessages: Set<CANMessage.ID> = .init()

    // Inspector
    @State var hasAutoOpenedInspector: Bool = false
    @State var inspectorVisible: Bool = false
    
    // Sheets & Alerts
    @State var presentClearMessagesAlert: Bool = false

    var body: some View {
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
        .inspector(isPresented: $inspectorVisible) {
            VStack {
                if let selectedMessageID = selectedMessages.first,
                   let selectedMessage = document.messages.first(where: { $0.id == selectedMessageID }) {
                    MessageDetail(message: selectedMessage)
                } else {
                    Text("No Currently Selected Message")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .inspectorColumnWidth(min: 150, ideal: 250, max: 400)
        }
        .onChange(of: selectedMessages) { oldValue, newValue in
            guard oldValue.isEmpty else { return }
            guard !newValue.isEmpty else { return }
            guard !hasAutoOpenedInspector else { return }
            
            inspectorVisible = true
        }
        .toolbar {
            ToolbarItem(id: "clear") {
                Button {
                    presentClearMessagesAlert.toggle()
                } label: {
                    Label("Clear", symbol: .clear)
                }
            }
            ToolbarItem(id: "sidebar") {
                Button {
                    inspectorVisible.toggle()
                } label: {
                    Label("Toggle Sidebar", symbol: .sidebar_right)
                }
            }
        }
        .alert("Clear all messages?", isPresented: $presentClearMessagesAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                document.messages.removeAll()
            }
        } message: {
            Text("This will clear all messages from the document, and is not reversible.")
        }

    }
}
