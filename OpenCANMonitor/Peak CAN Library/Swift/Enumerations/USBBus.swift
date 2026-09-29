//
//  USBBus.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

/// The eight supported USB buses available to PCAN
enum USBBus: CaseIterable, Identifiable {
    var id: UInt32 {
        rawValue
    }
    
    /// PCAN-USB interface, channel 1
    case bus1
    /// PCAN-USB interface, channel 2
    case bus2
    /// PCAN-USB interface, channel 3
    case bus3
    /// PCAN-USB interface, channel 4
    case bus4
    /// PCAN-USB interface, channel 5
    case bus5
    /// PCAN-USB interface, channel 6
    case bus6
    /// PCAN-USB interface, channel 7
    case bus7
    /// PCAN-USB interface, channel 8
    case bus8
    /// Undefined/default value for a PCAN bus
    case none
    
    /// The user facing display name for a USB Bus
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

extension USBBus: RawRepresentable {
    typealias RawValue = UInt32
    
    /// An optional RawRepresentable initializer that initializes a bus from its ``RawValue-swift.typealias``
    /// - Parameter rawValue: The rawValue to initialize with. Should be the UInt32 value that is found in the `PCBUSB.h` definitions.
    init?(rawValue: UInt32) {
        for element in Self.allCases {
            if element.rawValue == rawValue {
                self = element
                return
            }
        }
        return nil
    }
    
    /// The RawValue of the status. These values link back to the original C values found in `PCBUSB.h`
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
