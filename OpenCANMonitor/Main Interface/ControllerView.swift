//
//  ControllerView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI
import HydrogenReporter

struct ControllerView: View {
    @Environment(\.scenePhase) var scenePhase: ScenePhase
    @StateObject var channelMonitor: CanChannelMonitor = .init()
    @State var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State var selectedView: NavigableView = .connections

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(NavigableView.allCases, selection: $selectedView) { view in
                NavigationLink(value: view) {
                    Label(view.displayName, symbol: view.image)
                }
                .disabled(!channelMonitor.initializedViews.contains(view))
            }
        } detail: {
            switch selectedView {
            case .connections:
                ConnectionsView(selectedView: $selectedView)
            case .receiving:
                ReceivingTableView()
            case .transmitting:
                TransmitView()
            }
        }
        .environmentObject(channelMonitor)
        .onChange(of: scenePhase) { newValue in
            print(newValue, scenePhase)
            do {
                if newValue == .active {
                    // We need to reinitialize if we are entering back from a background state
                    channelMonitor.initTimers()
                    try channelMonitor.reInitialize() // Will silently fail if we are already initialized
                } else if newValue == .inactive {
                    // We just need to invalidate timers here because we can stay connected to CAN.
                    channelMonitor.invalidateTimers()
                } else if newValue == .background {
                    // We need to remove all initialization and connections because we may be cancelling.
                    channelMonitor.invalidateTimers()
                    try channelMonitor.uninitialize()
                }
            } catch {
                LOG("Scene Phase Change Failed", error, level: .error)
            }
        }
    }
}

struct ControllerView_Previews: PreviewProvider {
    static var previews: some View {
        ControllerView()
    }
}
