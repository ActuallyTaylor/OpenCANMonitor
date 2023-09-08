//
//  CanMonitorApp.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/4/23.
//

import SwiftUI

@main
struct CanMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ControllerView()
        }
        Settings {
            SettingsView()
        }
    }
}
