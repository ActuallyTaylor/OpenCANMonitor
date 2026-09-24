//
//  Connections.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import SwiftUI
import HydrogenReporter

struct StartupView: View {
    @Environment(\.openDocument) var openDocument
    @Environment(\.newDocument) var newDocument
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var presentConnectSheet: Bool = false
    @State var presentFileImporter: Bool = false
    
    @State var selected: URL? = nil
    
    @State var recentProjects: [URL] = []
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                VStack {
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

                    Image("OpenCanMonitor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .shadow(color: .accentColor.opacity(0.5), radius: 20)
                        .padding()
                    
                    Text("Open CAN Monitor")
                        .font(.title)
                    Text("Version \(appVersion)")
                }
                Spacer()
                Button {
                    presentConnectSheet.toggle()
                } label: {
                    Label("Connect to CAN dongle...", symbol: .cable_connector)
                }
                .buttonStyle(StartupButton())
                Button {
                    newDocument(contentType: .json)
                    dismissWindow()
                } label: {
                    Label("Create a new blank project...", symbol: .doc)
                }
                .buttonStyle(StartupButton())
                Button {
                    presentFileImporter.toggle()
                } label: {
                    Label("Open an existing project...", symbol: .arrow_down_doc)
                }
                .buttonStyle(StartupButton())
                Spacer()
            }
            .frame(width: 450)
            List(selection: $selected) {
                ForEach(recentProjects, id: \.absoluteString) { url in
                    Button {
                        // Prevent the button from activating if it is not selected
                        openDocument(at: url)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(url.deletingPathExtension().lastPathComponent)
                                .font(.headline)
                            // Change a path from /Users/taylor/EVT/can.json to ~/EVT/can.json
                            Text(url.path(percentEncoded: false).replacing(/\/Users\/[^\/]+\//, with: "~/"))
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)
                    .id(url)
                }
            }
            .listStyle(.sidebar)
        }
        .ignoresSafeArea()
        .rounded()
        .task {
            recentProjects = NSDocumentController.shared.recentDocumentURLs
            if selected == nil {
                selected = recentProjects.first
            }
        }
        .onKeyPress(.return) {
            if let selected {
                openDocument(at: selected)
                return .handled
            }
            
            return .ignored
        }
        .fileImporter(isPresented: $presentFileImporter, allowedContentTypes: [.json]) { completion in
            do {
                let result = try completion.get()
                guard result.startAccessingSecurityScopedResource() else {
                    LOG("Failed to access security scoped resource", level: .error)
                    return
                }
                
                openDocument(at: result)
            } catch  {
                LOG(error.localizedDescription, level: .error)
            }
        }
        .frame(width: 700, height: 400)
        .sheet(isPresented: $presentConnectSheet) {
            ConnectSheet { interface, baudRate in
                presentConnectSheet = false
                dismissWindow()
                newDocument(CANDocumentJSON(interface: interface, baudRate: baudRate))
            }
        }
    }
}

extension StartupView {
    private func openDocument(at url: URL) {
        Task {
            do {
                try await openDocument(at: url)
                dismissWindow()
            } catch {
                LOG(error.localizedDescription, level: .error)
            }
        }
    }
}

#Preview {
    StartupView()
}
