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
        WindowGroup("Startup") {
            Connections()
                .rounded()
        }
        .defaultLaunchBehavior(.presented)
        
        DocumentGroup(newDocument: CANDocumentJSON()) { configuration in
            DocumentView(document: configuration.document)
        }
//        WindowGroup {
//            ControllerView()
//                .rounded()
//        }
        Settings {
            SettingsView()
                .rounded()
        }
    }
}
