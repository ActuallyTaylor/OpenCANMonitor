//
//  ControllerView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct ControllerView: View {
    @StateObject var channelMonitor: CanChannelMonitor = .init()
    @State var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State var selectedView: NavigableView = .CANMessages

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(NavigableView.allCases, selection: $selectedView) { view in
                NavigationLink(view.displayName, value: view)
            }
        } detail: {
            CANTableView()
        }
        .environmentObject(channelMonitor)

    }
}

struct ControllerView_Previews: PreviewProvider {
    static var previews: some View {
        ControllerView()
    }
}
