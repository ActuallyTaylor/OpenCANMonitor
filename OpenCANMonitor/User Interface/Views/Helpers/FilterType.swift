//
//  FilterType.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

enum FilterType: Identifiable, CaseIterable {
    var id: String {
        displayName
    }
    
    case all
    case errors
    case warnings
    case errorsAndWarnings
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .errors:
            return "Errors"
        case .warnings:
            return "Warnings"
        case .errorsAndWarnings:
            return "Errors & Warnings"
        }
    }
}
