//
//  ConnectionsView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI
import HydrogenReporter

struct ConnectionsView: View {    
    @EnvironmentObject var channelMonitor: CanChannelMonitor
    
    @Binding var selectedView: NavigableView

    @State var presentConnectSheet: Bool = false

    @State var connectionError: CANStatus? = nil
    @State var presentConnectionError: Bool = false
    
    @State var loadingError: ErrorWrapper? = nil
    @State var presentLoadingError: Bool = false
    
    @State var magnifyingGlassOffset: CGSize = .zero
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Setup a Connection...")
                .font(.title)
            Image(.magnifyingglass)
                .resizable()
                .frame(width: 50, height: 50)
                .compatibleBold()
                .offset(magnifyingGlassOffset)
                .animation(.spring(), value: magnifyingGlassOffset)
                .onReceive(timer) { input in
                    magnifyingGlassOffset = .init(width: .random(in: -10...10), height: .random(in: -10...10))
                }
            HStack {
                Button {
                    presentConnectSheet.toggle()
                } label: {
                    Label("Connect Over USB", symbol: .desktopcomputer)
                }
                Button {
                    do {
                        try channelMonitor.load()
                    } catch {
                        loadingError = .init(internalError: error)
                        presentLoadingError = true
                    }
                } label: {
                    Label("Load a CAN Dump", symbol: .arrow_down_doc)
                }
            }
            .padding(.top, 20)
            .alert(isPresented: $presentLoadingError, error: loadingError, actions: { error in
                Button("Okay", role: .cancel) { }
            }, message: { error in
                Text("There was an error with loading your CAN Dump. Please make sure it is a valid JSON file.")
            })
            .alert(isPresented: $presentConnectionError, error: connectionError, actions: { error in
                Button("Okay", role: .cancel) { }
            }, message: { error in
                Text("There was an error originating from the CAN Driver. Please double check that you are plugged into a CAN Dongle. If you are, try re-plugging.")
            })
            .sheet(isPresented: $presentConnectSheet) {
                ConnectSheet { interface, baudRate in
                    do {
                        try channelMonitor.initialize(bus: interface, baudRate: baudRate)
                        
                        withAnimation {
                            presentConnectSheet = false
                            selectedView = .receiving
                        }
                    } catch {
                        guard let error = error as? CANStatus else {
                            LOG("Invalid Error Type. Error: ", error, level: .error)
                            return
                        }
                        LOG("Received CAN Error: ", error, level: .error)
                        connectionError = error
                        presentConnectionError = true
                    }
                }
            }
        }
        .navigationTitle("Connections")
    }
}

struct ConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionsView(selectedView: .constant(.connections))
    }
}
