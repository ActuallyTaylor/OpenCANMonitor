//
//  MessageDetail.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct MessageDetail: View {
    var message: CANMessage
    
    var body: some View {
        Form {
            Section {
                LabeledContent("ID", value: message.id.description)
                LabeledContent("Device", value: message.deviceID.hex(length: 3))
                LabeledContent("Time", value: message.timestamp)
                LabeledContent("Type", value: message.type.displayName)
            }
            
            Section("Data") {
                LabeledContent("Hex", value: message.data.description)
                LabeledContent("Decimal", value: message.data.decimal)
                LabeledContent("ASCII", value: message.data.ascii)
            }
        }
    }
}

struct MessageDetail_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetail(message: .init(id: 0, deviceID: 1, timestamp: "106242265:80", type: .standard, data: .init(byte0: 222, byte1: 173, byte2: 190, byte3: 190, byte4: 239, byte5: 0, byte6: 1, byte7: 2)))
    }
}
