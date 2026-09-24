//
//  CreateMessageSheet.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct CreateMessageSheet: View {
    enum Field: Hashable {
        case deviceID
        case length
        case hex(index: Int)
        case cycleTime
    }

    @Environment(\.dismiss) var dismiss
    
    @FocusState var focusedField: Field?
    
    @State var bytes: [String] = Array(repeating: "", count: 8)
    
    @State var dataLength: Int = 8
    @State var deviceID: String = ""
    @State var cycleTime: Int = 1000
    @State var presentValidationError: Bool = false
    
//    @FocusState

    var create: (MessageData, Int, UInt32, Int) -> ()

    var body: some View {
        Form {
            LabeledContent("ID (Hex)") {
                AKTextField(placeholder: "000", bezelStyle: .squareBezel, text: $deviceID, formatter: HexFormatter(characterLimit: 8))
                    .focused($focusedField, equals: .deviceID)
            }
            
            Picker("Length", selection: $dataLength) {
                ForEach(0..<9) { number in
                    Text(number.description)
                }
            }
            .focused($focusedField, equals: .length)
            .onChange(of: dataLength) { oldValue, newValue in
                if newValue > bytes.count {
                    bytes.append(contentsOf: Array(repeating: "", count: newValue - bytes.count))
                } else if newValue < bytes.count {
                    bytes.removeLast(bytes.count - newValue)
                }
            }
            
            LabeledContent("Data (Hex)") {
                dataFields
            }
            
            HStack {
                TextField("Cycle Time", value: $cycleTime, format: .number)
                    .textFieldStyle(.squareBorder)
                    .focused($focusedField, equals: .cycleTime)
                Text("ms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard validate() else {
                        presentValidationError.toggle()
                        return
                    }
                    
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
                }
            }

            ToolbarItem(placement: .cancellationAction) {
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
    
    var dataFields: some View {
        HStack(spacing: 3) {
            ForEach(Array(bytes.enumerated()), id: \.offset) { offset, _ in
                HexField(index: offset, hexString: $bytes[offset])
                    .focused($focusedField, equals: .hex(index: offset))
                    .onChange(of: bytes[offset]) { _, newValue in
                        // This allows the user to keep typing without having to tab through the individual data text boxes.
                        // Once the text reaches 2 characters (hex byte size) and there is another byte after this one, move the focused field forward.
                        // If the text reaches 0 characters and was greater than 0 characters we are deleting and should move back a text box.
                        if newValue.count == 2, offset < bytes.count - 1 {
                            focusedField = .hex(index: offset + 1)
                        }
                        
                        // This moves the field back as the user deletes characters. It didn't feel that good, as SwiftUI would select all of the text in the box instead of just putting the selection at the end of the field.
//                        else if newValue.count == 0 && oldValue.count > 0 {
//                            if offset > 0 {
//                                focusedField = .hex(index: offset - 1)
//                            }
//                        }
                    }
            }
        }
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
                    .frame(width: 30)
                Text(index.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CreateMessageSheet { _, _, _, _ in
        
    }
}
