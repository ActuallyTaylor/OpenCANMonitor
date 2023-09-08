//
//  ContentView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/4/23.
//

import SwiftUI
import SFSymbols
import HydrogenReporter

struct CANTableView: View {
    @EnvironmentObject var channelMonitor: CanChannelMonitor
    
    @State var presentAddMessage: Bool = false
    @State var presentFilter: Bool = false
    @State var presentConnectSheet: Bool = false
    @State var presentError: Bool = false

    @State var canError: PCANError? = nil
            
    @State var hexDataFilter: String = ""
    @State var asciiDataFilter: String = ""
    @State var messageType: FilterType = .all
    
    @State var selectedMessages: Set<CANMessage.ID> = .init()
    
    @State var splitOnePercent: CGFloat = 1
    @State var splitTwoPercent: CGFloat = 0

    var body: some View {
//        VSplitView {
            ScrollViewReader { reader in
                Table(channelMonitor.messages, selection: $selectedMessages) {
                    TableColumn("Number", value: \.id.description)
                        .width(25)
                    TableColumn("Time", value: \.timestamp)
                    TableColumn("Device ID") { message in
                        Text(message.deviceID.hex(length: 3))
                    }
                    .width(25)
                    TableColumn("Type", value: \.type.displayName)
                        .width(50)
                    TableColumn("Hex Data", value: \.data.description)
                    TableColumn("ASCII Data", value: \.data.ascii)
                    TableColumn("Decimal Data", value: \.data.decimal)

                }
                .tableStyle(.inset)
                .onChange(of: channelMonitor.messages) { newValue in
                    reader.scrollTo(newValue.last?.id)
                }
            }
//            VStack(spacing: 0) {
//                HStack(alignment: .center) {
//                    Button(.rectangle_bottomthird_inset_filled) {
//                        withAnimation {
//                            toggleSplit()
//                        }
//                    }
//                    .buttonStyle(.plain)
//                    .padding(.leading, 10)
//                    .padding(.vertical, 5)
//                    .imageScale(.small)
//                    Spacer()
//                }
//                .background(Color(nsColor: .separatorColor))
//                if let selectedMessage = channelMonitor.messages.first(where: { message in
//                    return message.id == selectedMessages.first
//                }) {
//                    ScrollView {
//                        MessageDetail(message: selectedMessage)
//                    }
//                }
//            }
//        }
        .navigationTitle("CAN Messages")
        .toolbar(id: "options") {
            ToolbarItem(id: "saveJSON") {
                Button("Save") {
                    do {
                        try channelMonitor.save()
                    } catch {
                        print("Serialization Error \(error)")
                    }
                }
            }
            ToolbarItem(id: "loadJSON") {
                Button("Load") {
                    do {
                        try channelMonitor.load()
                    } catch {
                        print("Serialization Error \(error)")
                    }
                }
            }

            ToolbarItem(id: "newConnection", placement: .primaryAction) {
                Button {
                    presentConnectSheet = true
                } label: {
                    Label("New Connection", symbol: .plus)
                }
            }
            ToolbarItem(id: "clear", placement: .destructiveAction) {
                Button {
                    channelMonitor.clearMessages()
                } label: {
                    Label("Clear", symbol: .clear)
                }
            }
            ToolbarItem(id: "sendMessage", placement: .primaryAction) {
                Button {
                    presentAddMessage.toggle()
                } label: {
                    Label("Send Message", symbol: .paperplane)
                }
                .popover(isPresented: $presentAddMessage) {
                    SendMessagePopover()
                }
            }
            ToolbarItem(id: "filter", placement: .primaryAction) {
                Button {
                    presentFilter.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Text("All Messages")
                            .font(.body)
                        Image(.chevron_down)
                    }
                }
                .popover(isPresented: $presentFilter) {
                    FilterMessagesPopover(hexDataFilter: $hexDataFilter, asciiDataFilter: $asciiDataFilter, messageType: $messageType)
                }
            }
        }
        .sheet(isPresented: $presentConnectSheet) {
            ConnectSheet { interface, baudRate in
                do {
                    try channelMonitor.initialize(bus: interface, baudRate: baudRate)
                    
                    withAnimation {
                        presentConnectSheet = false
                    }
                } catch {
                    guard let error = error as? PCANError else {
                        LOG("Invalid Error Type. Error: ", error, level: .error)
                        return
                    }
                    LOG("Received CAN Error: ", error, level: .error)
                    canError = error
                    presentError = true
                }
            }
        }
        .alert(isPresented: $presentError, error: canError, actions: { error in
            Button("Okay", role: .cancel) { }
        }, message: { error in
            Text("There was an error originating from the CAN Driver. Please double check that you are plugged into a CAN Dongle. If you are, try re-plugging.")
        })
        .onAppear {
            if !channelMonitor.initialized {
                presentConnectSheet = true
            }
        }
    }
    
    private func toggleSplit() {
        if splitOnePercent == 1 {
            splitOnePercent = 0.75
            splitTwoPercent = 0.25
        } else {
            splitOnePercent = 1
            splitTwoPercent = 0
        }
    }
}

struct CANTableView_Previews: PreviewProvider {
    static var previews: some View {
        CANTableView()
    }
}
