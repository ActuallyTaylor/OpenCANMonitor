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
        VStack(alignment: .leading, spacing: 5) {
            Text("Can Message #\(message.id)")
                .font(.title)
                .bold()
            Text("**Device:** 0x\(message.deviceID.hex(length: 3))")
            Text("**Time:** \(message.timestamp)")
            Text("**Type:** \(message.type.displayName)")
            Divider()
            Text("**Hex:** \(message.data.description)")
            Text("**Decimal:** \(message.data.decimal)")
            Text("**ASCII:** \(message.data.ascii)")
        }
        .padding()
    }
}

struct MessageDetail_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetail(message: .init(id: 0, deviceID: 1, timestamp: "106242265:80", type: .standard, data: .init(byte0: 222, byte1: 173, byte2: 190, byte3: 190, byte4: 239, byte5: 0, byte6: 1, byte7: 2)))
    }
}
