//
//  RoundedFont.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

extension View {
    func rounded() -> some View {
//        if #available(macOS, *) {
            return self.fontDesign(.rounded)
//        } else {
//            return self
//        }
    }
}
