//
//  GeneralSettingsView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/7/23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @State var setDefaults: Bool = false

    // Funky storage settings because AppStorage does not like UInt32 RawRepresentable
    @AppStorage("defaultBus") var defaultBus: Int = 0
    @AppStorage("defaultBaud") var defaultBaud: Int = 0
    
    @State var usbBus: PCANUSBBus = .bus1
    @State var baudRate: PCANBaudRate = .baud1M
    
    var body: some View {
        Form {
            Picker("Default Interface", selection: $usbBus) {
                // Loop over all the interfaces, but drop the last because it is the none interface.
                ForEach(PCANUSBBus.allCases.dropLast()) { interface in
                    Text(interface.displayName)
                        .tag(interface)
                }
            }
            .onChange(of: usbBus) { newValue in
                defaultBus = PCANUSBBus.allCases.firstIndex(of: newValue)!
            }
            
            Picker("Default Baud Rate", selection: $baudRate) {
                ForEach(PCANBaudRate.allCases) { rate in
                    Text(rate.displayName)
                        .tag(rate)
                }
            }
            .onChange(of: baudRate) { newValue in
                defaultBaud = PCANBaudRate.allCases.firstIndex(of: newValue)!
            }
        }
        .onAppear {
            guard !setDefaults else { return }
            setDefaults = true
            let defaultBusIndex = UserDefaults.standard.integer(forKey: "defaultBus")
            let defaultBaudIndex = UserDefaults.standard.integer(forKey: "defaultBaud")
            
            usbBus = PCANUSBBus.allCases[defaultBusIndex]
            baudRate = PCANBaudRate.allCases[defaultBaudIndex]
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
