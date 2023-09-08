//
//  FilterMessagesPopover.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI

struct FilterMessagesPopover: View {
    @Binding var hexDataFilter: String
    @Binding var asciiDataFilter: String
    @Binding var messageType: FilterType
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                VStack(alignment: .leading) {
                    AKTextField(placeholder: "Hex Data Filter", text: $hexDataFilter, formatter: HexFormatter(byteLimit: 8))
                        .frame(idealWidth: 250)
                    Text("All messages **must** contain the specified **hex** data")
                        .font(.caption)
                        .foregroundColor(.secondary)

                }
                VStack(alignment: .leading) {
                    AKTextField(placeholder: "ASCII Data Filter", text: $asciiDataFilter)
                        .frame(idealWidth: 250)
                    Text("All messages **must** contain the specified **ascii** data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 5)
            
            Text("Show:")
                .bold()
            Picker(selection: $messageType) {
                ForEach(FilterType.allCases) { type in
                    Text(type.displayName)
                        .tag(type)
                }
            } label: {
                
            }
            .pickerStyle(RadioGroupPickerStyle())

        }
        .padding()
    }
}

struct FilterMessagesPopover_Previews: PreviewProvider {
    static var previews: some View {
        FilterMessagesPopover(hexDataFilter: .constant(""), asciiDataFilter: .constant(""), messageType: .constant(.all))
    }
}
