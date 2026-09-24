//
//  Tools.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 10/1/25.
//

import SFSymbols

enum Tool: Int, CaseIterable, Identifiable{
    var id: Int { rawValue }
    
    case bus = 0
    case transmit = 1
    
    var displayName: String {
        switch self {
        case .bus:
            return "Bus Traffic"
        case .transmit:
            return "Transmit"
        }
    }
    
    var image: SFSymbol {
        switch self {
        case .bus:
            .rectangle_grid_1x3
        case .transmit:
            .paperplane
        }
    }
}
