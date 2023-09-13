//
//  CANMessageType.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

/// The 9 types of CAN messages.
enum CANMessageType: CaseIterable, Identifiable, Codable {
    /// The ID of the ``CANMessageType`` used for easily looping in `SwiftUI`
    var id: UInt32 {
        rawValue
    }
    
    /// The PCAN message is a CAN Standard Frame (11-bit identifier)
    case standard
    /// The PCAN message is a CAN Remote-Transfer-Request Frame
    case rtr
    /// The PCAN message is a CAN Extended Frame (29-bit identifier)
    case extended
    /// The PCAN message represents a FD frame in terms of CiA Specs
    case fd
    /// The PCAN message represents a FD bit rate switch (CAN data at a higher bit rate)
    case brs
    /// The PCAN message represents a FD error state indicator (CAN FD transmitter was error active)
    case esi
    /// The PCAN message represents an echo CAN Frame
    case echo
    /// The PCAN message represents an error frame
    case errFrame
    /// The PCAN message represents a PCAN status message
    case status
    
    /// The user facing display name for the type of CAN Message.
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

extension CANMessageType: RawRepresentable {
    typealias RawValue = UInt32
    
    /// An optional RawRepresentable initializer that initializes a status from its ``RawValue-swift.typealias``
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
    
    /// The RawValue of the message type. These values link back to the original C values found in `PCBUSB.h`
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
