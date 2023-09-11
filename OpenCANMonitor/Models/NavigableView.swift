//
//  NavigableViews.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation
import SFSymbols

enum NavigableView: CaseIterable, Identifiable, Hashable {
    var id: String {
        displayName
    }
    
    case connections
    case receiving
    case transmitting
    
    var displayName: String {
        switch self {
        case .connections:
            return "Connections"
        case .receiving:
            return "Receiving Messages"
        case .transmitting:
            return "Transmitting Messages"
        }
    }
    
    var image: SFSymbol {
        switch self {
        case .connections:
            return .magnifyingglass
        case .receiving:
            return .mail_stack
        case .transmitting:
            return .paperplane
        }
    }
}
