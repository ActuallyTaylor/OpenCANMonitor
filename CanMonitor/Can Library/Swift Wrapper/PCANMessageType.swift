//
//  PCANMessageType.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

enum PCANMessageType: CaseIterable, Identifiable, Codable {
    var id: UInt32 {
        rawValue
    }
    
    case standard
    case rtr
    case extended
    case fd
    case brs
    case esi
    case echo
    case errFrame
    case status
    
    var displayName: String {
        switch self {
        case .standard:
            return "Standard Frame"
        case .rtr:
            return "Remote-Transfer-Request Frame"
        case .extended:
            return "Extended Frame"
        case .fd:
            return "FD frame"
        case .brs:
            return "FD bit rate switch"
        case .esi:
            return "FD error state indicator"
        case .echo:
            return "Echo Frame"
        case .errFrame:
            return "Error Frame"
        case .status:
            return "Status Message"
        }
    }
}

extension PCANMessageType: RawRepresentable {
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
        case .standard:
            return PCAN_MESSAGE_STANDARD
        case .rtr:
            return PCAN_MESSAGE_RTR
        case .extended:
            return PCAN_MESSAGE_EXTENDED
        case .fd:
            return PCAN_MESSAGE_FD
        case .brs:
            return PCAN_MESSAGE_BRS
        case .esi:
            return PCAN_MESSAGE_ESI
        case .echo:
            return PCAN_MESSAGE_ECHO
        case .errFrame:
            return PCAN_MESSAGE_ERRFRAME
        case .status:
            return PCAN_MESSAGE_STATUS
        }
    }
}
