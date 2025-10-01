//
//  OpenCANMonitorApp.swift
//  OpenCANMonitorApp
//
//  Created by Taylor Lineman on 9/4/23.
//

import SwiftUI

enum WindowID: String {
    case startup = "Startup"
}

@main
struct OpenCANMonitorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: CANDocumentJSON()) { configuration in
            DocumentControllerView(documentURL: configuration.fileURL, document: configuration.document)
                .rounded()
        }

        WindowGroup(WindowID.startup.rawValue) {
            StartupView()
                .rounded()
                .containerBackground(.thickMaterial, for: .window)
                .windowFullScreenBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
        }
        .windowIdealSize(.fitToContent)
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowIdealPlacement  { content, context in
            return WindowPlacement(.center)
        }
        .defaultWindowPlacement { _, _ in
            return WindowPlacement(.center)
        }
        .defaultLaunchBehavior(.presented)
                
        Settings {
            SettingsView()
                .rounded()
        }
    }
}
//
//public struct ToolCommands: Commands {
//    @Environment(\.openWindow) private var openWindow
//
//    public var body: some Commands {
//        CommandMenu("Tools") {
//            Button("Transmit Messages") {
//                openWindow(id: WindowID.transmit.rawValue)
//            }
//            
//            Button("Startup Menu") {
//                openWindow(id: WindowID.transmit.rawValue)
//            }
//        }
//    }
//}
//
//
//
//
