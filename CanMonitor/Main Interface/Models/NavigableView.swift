//
//  NavigableViews.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

enum NavigableView: CaseIterable, Identifiable, Hashable {
    var id: String {
        displayName
    }
    
    case connections
    case CANMessages
    
    var displayName: String {
        switch self {
        case .connections:
            return "Connections"
        case .CANMessages:
            return "Messages"
        }
    }
}
