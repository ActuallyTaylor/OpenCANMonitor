//
//  TransmitView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI
import SFSymbols
import SwiftData

struct TransmitView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transmitMessages: [CANTransmitMessage]
    
    @Binding var document: JSONCANDocument
    @Binding var controller: BusController?

    @State var selectedMessages: Set<CANTransmitMessage.ID> = .init()
    
    @State var presentCreateMessageSheet: Bool = false
    @State var editingMessage: CANTransmitMessage? = nil

    var body: some View {
        HStack(spacing: 0) {
            Table(of: CANTransmitMessage.self, selection: $selectedMessages) {
                TableColumn("Active") { message in
                    Toggle("Active", isOn: Binding<Bool>(get: {
                        message.currentlyTransmitting
                    }, set: { newValue in
                        message.currentlyTransmitting = newValue
                    }))
                    .labelsHidden()
                    .disabled(controller == nil)
                    .help(controller == nil ? "You can only send messages when connected to a CAN Dongle" : "Whether or not the transmit message is sent over the CAN bus.")
                }
                .width(50)
                TableColumn("Device ID") { message in
                    Text(message.deviceID.hex(length: 3))
                }
                .width(min: 5, ideal: 25)
                TableColumn("Type", value: \.type.displayName)
                    .width(min: 5, ideal: 50)
                TableColumn("Hex Data", value: \.data.description)
                TableColumn("ASCII Data", value: \.data.ascii)
                TableColumn("Decimal Data", value: \.data.decimal)
                TableColumn("Cycle Time", value: \.cycleTime.description)
            } rows: {
                ForEach(transmitMessages) { message in
                    TableRow(message)
                        .contextMenu {
                            Button {
                                editingMessage = message
                            } label: {
                                Label("Edit", symbol: .wrench_and_screwdriver)
                            }
                            Button(role: .destructive) {
                                modelContext.delete(message)
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                }
            }
            .tableStyle(.inset)
        }
        .navigationTitle("Transmitting Messages")
        .toolbar {
            ToolbarItem(id: "addItem") {
                Button {
                    presentCreateMessageSheet.toggle()
                } label: {
                    Label("Add Message", symbol: .plus)
                }
            }
        }
        .sheet(isPresented: $presentCreateMessageSheet) {
            CreateMessageSheet { data, dataLength, deviceID, cycleTime in
                let message = CANTransmitMessage(
                    deviceID: deviceID,
                    type: .standard,
                    data: MessageData(bytes: data),
                    length: dataLength,
                    cycleTime: cycleTime,
                    currentlyTransmitting: false
                )
                modelContext.insert(message)
            }
        }
        .sheet(item: $editingMessage) { message in
            let displayBytes = message.data.array.map({$0.hex(length: 2)})
            let deviceID = message.deviceID.hex(length: 3)
            
            CreateMessageSheet(displayBytes: displayBytes, dataLength: message.length, deviceID: deviceID, cycleTime: message.cycleTime) { data, dataLength, deviceID, cycleTime in
                editingMessage?.data = MessageData(bytes: data)
                editingMessage?.length = dataLength
                editingMessage?.deviceID = deviceID
                editingMessage?.cycleTime = cycleTime
            }
        }
        .onChange(of: transmitMessages, initial: true) { _, newValue in
            controller?.setTransmitMessages(messages: newValue)
        }
    }
}

