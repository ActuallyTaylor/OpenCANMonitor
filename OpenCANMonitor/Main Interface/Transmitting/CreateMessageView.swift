//
//  CreateMessageView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct CreateMessageView: View {
    @Environment (\.dismiss) var dismiss
    @State var bytes: [String] = Array(repeating: "", count: 8)
    
    @State var dataLength: Int = 8
    @State var deviceID: String = ""
    @State var cycleTime: Int = 1000
    @State var presentValidationError: Bool = false

    var create: (CANMessage.MessageData, Int, UInt32, Int) -> ()

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("ID: (Hex)")
                        .bold()
                    AKTextField(placeholder: "000", bezelStyle: .squareBezel, text: $deviceID, formatter: HexFormatter(characterLimit: 8))
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Length:")
                        .bold()
                    Picker("Length", selection: $dataLength) {
                        ForEach(0..<9) { number in
                            Text(number.description)
                        }
                    }
                }
            }
            Divider()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Data: (Hex)")
                        .bold()
                    HStack(spacing: 3) {
                        ForEach(0..<8) { index in
                            HexField(index: index, hexString: $bytes[index])
                        }
                    }
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Text("Cycle Time: (ms)")
                    .bold()
                HStack {
                    TextField("Cycle Time", value: $cycleTime, format: .number)
                        .textFieldStyle(.squareBorder)
                    Text("ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button("Save") {
                    if validate() {
                        guard let b0 = UInt8(bytes[0], radix: 16),
                              let b1 = UInt8(bytes[1], radix: 16),
                              let b2 = UInt8(bytes[2], radix: 16),
                              let b3 = UInt8(bytes[3], radix: 16),
                              let b4 = UInt8(bytes[4], radix: 16),
                              let b5 = UInt8(bytes[5], radix: 16),
                              let b6 = UInt8(bytes[6], radix: 16),
                              let b7 = UInt8(bytes[7], radix: 16) else {
                            presentValidationError.toggle()
                            return
                        }
                        guard let hexDeviceID = UInt32(deviceID, radix: 16) else {
                            presentValidationError.toggle()
                            return
                        }
                        create(.init(byte0: b0, byte1: b1, byte2: b2, byte3: b3, byte4: b4, byte5: b5, byte6: b6, byte7: b7),
                               dataLength,
                               hexDeviceID,
                               cycleTime)
                        dismiss()
                    } else {
                        presentValidationError.toggle()
                    }
                }

                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .padding()
        .alert("Validation Error", isPresented: $presentValidationError, actions: {
            Button("Cancel", role: .cancel) { }
        }, message: {
            Text("Please fill in all of the data before saving your CAN Transmit Message")
        })
    }
    
    private func validate() -> Bool {
        for (offset, byte) in bytes.enumerated() {
            if offset >= dataLength { break }
            if byte == "" {
                print("Empty Byte \(offset)")
                return false
            }
        }
        
        if deviceID == "" {
            print("Empty Device")
            return false
        }
        
        return true
    }
    
    struct HexField: View {
        let index: Int
        @Binding var hexString: String
        
        var body: some View {
            VStack {
                AKTextField(placeholder: "00", bezelStyle: .squareBezel, text: $hexString, formatter: HexFormatter(characterLimit: 2))
                    .frame(width: 25)
                Text(index.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CreateMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMessageView { _, _, _, _ in
            
        }
    }
}

/*
 let id: Int
 let deviceID: UInt32
 let type: PCANMessageType
 let data: CANMessage.MessageData
 var currentlyTransmitting: Bool
 */
