//
//  OpenCANMonitorApp.swift
//  OpenCANMonitorApp
//
//  Created by Taylor Lineman on 9/4/23.
//

import SwiftUI

@main
struct OpenCANMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ControllerView()
                .rounded()
        }
        Settings {
            SettingsView()
                .rounded()
        }
    }
}
