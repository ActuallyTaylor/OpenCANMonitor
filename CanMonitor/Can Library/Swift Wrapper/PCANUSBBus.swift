//
//  PCANUSBBus.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

// The eight supported USB buses available to PCAN
enum PCANUSBBus: CaseIterable, Identifiable {
    var id: UInt32 {
        rawValue
    }
    
    case none
    case bus1
    case bus2
    case bus3
    case bus4
    case bus5
    case bus6
    case bus7
    case bus8
    
    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .bus1:
            return "Bus 1"
        case .bus2:
            return "Bus 2"
        case .bus3:
            return "Bus 3"
        case .bus4:
            return "Bus 4"
        case .bus5:
            return "Bus 5"
        case .bus6:
            return "Bus 6"
        case .bus7:
            return "Bus 7"
        case .bus8:
            return "Bus 8"
        }
    }
}

extension PCANUSBBus: RawRepresentable {
    typealias RawValue = UInt32
    
    init?(rawValue: UInt32) {
        for element in Self.allCases {
            if element.rawValue == rawValue {
                self = element
                return
            }
        }
        return nil
    }
    
    var rawValue: UInt32 {
        switch self {
        case .none:
            return PCAN_NONEBUS
        case .bus1:
            return PCAN_USBBUS1
        case .bus2:
            return PCAN_USBBUS2
        case .bus3:
            return PCAN_USBBUS3
        case .bus4:
            return PCAN_USBBUS4
        case .bus5:
            return PCAN_USBBUS5
        case .bus6:
            return PCAN_USBBUS6
        case .bus7:
            return PCAN_USBBUS7
        case .bus8:
            return PCAN_USBBUS8
        }
    }
}
