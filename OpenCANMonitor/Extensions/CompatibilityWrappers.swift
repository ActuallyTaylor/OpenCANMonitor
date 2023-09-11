//
//  CompatibilityWrappers.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

extension View {
    func rounded() -> some View {
        if #available(macOS 13.0, *) {
            return self.fontDesign(.rounded)
        } else {
            return self
        }
    }
    
    func compatibleBold() -> some View {
        if #available(macOS 13.0, *) {
            return self.bold()
        } else {
            return self
        }
    }
}
