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
            StartupView()
                .rounded()
        }
        .windowIdealSize(.fitToContent)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .windowIdealPlacement  { content, context in
            return WindowPlacement(.center)
        }
        .defaultWindowPlacement { _, _ in
            return WindowPlacement(.center)
        }
        .defaultLaunchBehavior(.presented)
        
        DocumentGroup(newDocument: CANDocumentJSON()) { configuration in
            DocumentView(documentURL: configuration.fileURL, document: configuration.document)
                .rounded()
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
