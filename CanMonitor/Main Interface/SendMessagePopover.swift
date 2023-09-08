//
//  SendMessageView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI

struct SendMessagePopover: View {
    @State var id: String = ""
    @State var message: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                AKTextField(placeholder: "ID (Hex)", text: $id, formatter: HexFormatter(byteLimit: 8))
                    .frame(idealWidth: 250)
                Text("Maximum 29 bits (3.625 Bytes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading) {
                AKTextField(placeholder: "Data (Hex)", text: $message, formatter: HexFormatter(byteLimit: 8))
                    .frame(idealWidth: 250)
                Text("Max 8 Bytes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack {
                Button {
                    
                } label: {
                    Text("Transmit Message")
                }

            }
        }
        .padding()
    }
}

struct SendMessagePopover_Previews: PreviewProvider {
    static var previews: some View {
        SendMessagePopover()
    }
}
