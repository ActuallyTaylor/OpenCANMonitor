//
//  StartupButton.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/30/25.
//

import SwiftUI

struct StartupButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .frame(width: 300, height: 35)
        .background(Color(nsColor: NSColor.secondarySystemFill))
        .clipShape(.rect(cornerRadius: 10))
        .fontWeight(.semibold)
    }
}
