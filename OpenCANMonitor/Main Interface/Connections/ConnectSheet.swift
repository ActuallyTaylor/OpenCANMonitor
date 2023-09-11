//
//  ConnectSheet.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI

struct ConnectSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var setDefaults: Bool = false
    
    @State var usbBus: PCANUSBBus = .bus1
    @State var baudRate: PCANBaudRate = .baud1M
    
    var connect: (PCANUSBBus, PCANBaudRate) -> ()
    
    var body: some View {
        VStack {
            Text("Setup Connection")
                .font(.headline)
            Picker("Interface", selection: $usbBus) {
                // Loop over all the interfaces, but drop the last because it is the none interface.
                ForEach(PCANUSBBus.allCases.dropLast()) { interface in
                    Text(interface.displayName)
                        .tag(interface)
                }
            }
            Picker("Baud Rate", selection: $baudRate) {
                ForEach(PCANBaudRate.allCases) { rate in
                    Text(rate.displayName)
                        .tag(rate)
                }
            }
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Button("Connect") {
                    connect(usbBus, baudRate)
                }
            }
        }
        .padding()
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

struct ConnectSheet_Previews: PreviewProvider {
    static var previews: some View {
        ConnectSheet { interface, baudRate in
            
        }
    }
}
