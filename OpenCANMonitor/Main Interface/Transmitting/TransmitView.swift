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
    
    @State var presentCreateMessageView: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            ScrollViewReader { reader in
                Table(of: CANTransmitMessage.self, selection: $selectedMessages) {
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
                    TableColumn("Active") { message in
                        Toggle("Active", isOn: $channelMonitor[message.id].currentlyTransmitting)
                            .labelsHidden()
                    }
                    .width(50)
                } rows: {
                    ForEach(channelMonitor.transmittingMessages) { message in
                        TableRow(message)
                            .contextMenu {
                                Button(role: .destructive) {
                                    channelMonitor.transmittingMessages.removeAll { msg in
                                        return msg.id == message.id
                                    }
                                    try? channelMonitor.saveTransmittingMessages()
                                } label: {
                                    Text("Delete")
                                        .foregroundColor(.red)
                                }
                            }
                    }
                }
                .tableStyle(.inset)
            }
        }
        .navigationTitle("Transmiting Messages")
        .toolbar {
            ToolbarItem(id: "addItem") {
                Button {
                    presentCreateMessageView.toggle()
                } label: {
                    Label("Add Message", symbol: .plus)
                }
            }
        }
        .sheet(isPresented: $presentCreateMessageView) {
            CreateMessageView { data, dataLength, deviceID, cycleTime in
                let transmitMessage = CANTransmitMessage(deviceID: deviceID, type: .standard, data: data, length: dataLength, cycleTime: cycleTime, currentlyTransmitting: true)
                channelMonitor.transmittingMessages.append(transmitMessage)
                presentCreateMessageView = false
                try? channelMonitor.saveTransmittingMessages()
            }
        }
    }
}

struct TransmitView_Previews: PreviewProvider {
    static var previews: some View {
        TransmitView()
    }
}
