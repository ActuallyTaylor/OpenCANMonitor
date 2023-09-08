//
//  PCANBaudRate.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

/// Baud Rates recognized by PCBUSB
enum PCANBaudRate: CaseIterable, Identifiable {
    var id: UInt32 {
        rawValue
    }
    
    /// 1MBit/s
    case baud1M
    /// 800 kBit/s
    case baud800K
    /// 500 kBit/s
    case baud500K
    /// 250 kBit/s
    case baud250k
    /// 125 kBit/s
    case baud125K
    /// 100 kBit/s
    case baud100K
    /// 95.238 kBit/s
    case baud95K
    /// 83.333 kBit/s
    case baud83K
    /// 50.kBit/s
    case baud50K
    /// 47.619 kBit/s
    case baud47K
    /// 33.333 kBit/s
    case baud33K
    /// 20 kBit/s
    case baud20K
    /// 10 kBit/s
    case baud10K
    /// 5 kBit/s
    case baud5K
    
    case none
    
    var displayName: String {
        switch self {
        case .baud1M:
            return "1MBit/s"
        case .baud800K:
            return "800 kBit/s"
        case .baud500K:
            return "500 kBit/s"
        case .baud250k:
            return "250 kBit/s"
        case .baud125K:
            return "125 kBit/s"
        case .baud100K:
            return "100 kBit/s"
        case .baud95K:
            return "95.238 kBit/s"
        case .baud83K:
            return "83.333 kBit/s"
        case .baud50K:
            return "50.kBit/s"
        case .baud47K:
            return "47.619 kBit/s"
        case .baud33K:
            return "33.333 kBit/s"
        case .baud20K:
            return "20 kBit/s"
        case .baud10K:
            return "10 kBit/s"
        case .baud5K:
            return "5 kBit/s"
        case .none:
            return "none"
        }
    }
}

extension PCANBaudRate: RawRepresentable {
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
        case .baud1M:
            return PCAN_BAUD_1M
        case .baud800K:
            return PCAN_BAUD_800K
        case .baud500K:
            return PCAN_BAUD_500K
        case .baud250k:
            return PCAN_BAUD_250K
        case .baud125K:
            return PCAN_BAUD_125K
        case .baud100K:
            return PCAN_BAUD_100K
        case .baud95K:
            return PCAN_BAUD_95K
        case .baud83K:
            return PCAN_BAUD_83K
        case .baud50K:
            return PCAN_BAUD_50K
        case .baud47K:
            return PCAN_BAUD_47K
        case .baud33K:
            return PCAN_BAUD_33K
        case .baud20K:
            return PCAN_BAUD_20K
        case .baud10K:
            return PCAN_BAUD_10K
        case .baud5K:
            return PCAN_BAUD_5K
        case .none:
            return 0
        }
    }
}

