//
//  Connections.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/29/25.
//

import SwiftUI
import HydrogenReporter

struct RecentController {
    
    static var key: String = "recents"
        
    static func addRecent(url: URL) {
        if var paths = UserDefaults.standard.array(forKey: key) as? [String] {
            let path = url.path()
            
            // Remove existing path from the paths array
            if paths.contains(path) {
                paths.removeAll(where: {$0 == path})
            }
            
            // Insert the path into the top of the list
            paths.insert(path, at: 0)
            
            // If the URLs are already saved, retrieve them, and append a url.
            // Save it back into user defaults
            UserDefaults.standard.set(paths, forKey: key)
        } else {
            // If no URLs have been saved, create a new array and save it
            let paths: [String] = [url.path()]
            UserDefaults.standard.set(paths, forKey: key)
        }
    }
    
    static func getRecents() -> [URL] {
        // Get the array of paths from user defaults
        guard let paths = UserDefaults.standard.array(forKey: key) as? [String] else { return [] }
        // Map the paths into URLs using the filePath initializer
        var urls: [URL] = paths.map({URL(filePath: $0)})
        
        // Filter out any paths that no longer exist on the file system.
        urls = urls.filter { url in
            FileManager.default.fileExists(atPath: url.path())
        }
        
        // Save filtered paths back into user defaults
        UserDefaults.standard.set(urls.map({$0.path}), forKey: key)
        
        return urls
    }
}


struct StartupView: View {
    @Environment(\.openDocument) var openDocument
    @Environment(\.newDocument) var newDocument
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var presentConnectSheet: Bool = false
    @State var presentFileImporter: Bool = false
    
    @State var selected: URL? = nil
    
    var recentProjects: [URL] = RecentController.getRecents()
    
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
                    Label("Create a new project...", symbol: .doc)
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
                            Text(url.path().replacing(/\/Users\/[^\/]+\//, with: "~/"))
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
        .onAppear {
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
                newDocument(CANDocumentJSON(interface: interface, baudRate: baudRate))
                dismissWindow()
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
