//
//  CANStatus.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

/// A CAN status code that is returned by almost all **PCBUSB Library** functions
enum CANStatus: CaseIterable, LocalizedError {
    /// No error.
    case ok
    /// Transmit buffer in CAN controller is full.
    case xmtfull
    /// CAN controller was read too late.
    case overrun
    /// Bus error: an error counter reached the 'light' limit.
    case buslight
    /// Bus error: an error counter reached the 'heavy' limit.
    case busheavy
    /// Bus error: an error counter reached the 'warning' limit.
    case buswarning
    /// Bus error: the CAN controller is error passive.
    case buspassive
    /// Bus error: the CAN controller is in bus-off state.
    case busoff
    /// Mask for all bus errors.
    case anybuserr
    /// Receive queue is empty.
    case qrcvempty
    /// Receive queue was read too late.
    case qoverrun
    /// Transmit queue is full.
    case qxmtfull
    /// Test of the CAN controller hardware registers failed (no hardware found).
    case regtest
    /// Driver not loaded. (`libPCBUSB.dyld` did not load correctly).
    case nodriver
    /// Hardware already in use by a Net.
    case hwinuse
    /// A Client is already connected to the Net.
    case netinuse
    /// Hardware handle is invalid.
    case illhw
    ///Net handle is invalid.
    case illnet
    /// Client handle is invalid.
    case illclient
    /// Mask for all handle errors.
    case illhandle
    /// Resource (FIFO, Client, timeout) cannot be created.
    case resource
    /// Invalid parameter.
    case illparamtype
    /// Invalid parameter value.
    case illparamval
    /// Unknown error.
    case unknown
    /// Invalid data, function, or action
    case illdata
    /// Driver object state is wrong for the attempted operation.
    case illmode
    /// An operation was successfully carried out, however, irregularities were registered.
    case caution
    /// Channel is not initialized.
    case initialize
    /// Invalid operation.
    case illoperation
    
    /// The description of the error. Originally sourced from `PCBUSB.h`
    var errorDescription: String? {
        switch self {
        case .ok:
            return "No Error"
        case .xmtfull:
            return "Transmit buffer in CAN controller is full"
        case .overrun:
            return "CAN controller was read too late"
        case .buslight:
            return "Bus error: an error counter reached the 'light' limit"
        case .busheavy:
            return "Bus error: an error counter reached the 'heavy' limit"
        case .buswarning:
            return "Bus error: an error counter reached the 'warning' limit"
        case .buspassive:
            return "Bus error: the CAN controller is error passive"
        case .busoff:
            return "Bus error: the CAN controller is in bus-off state"
        case .anybuserr:
            return "Mask for all bus errors"
        case .qrcvempty:
            return "Receive queue is empty"
        case .qoverrun:
            return "Receive queue was read too late"
        case .qxmtfull:
            return "Transmit queue is full"
        case .regtest:
            return "Test of the CAN controller hardware registers failed (no hardware found)"
        case .nodriver:
            return "Driver not loaded. ('libPCBUSB.dyld' did not load correctly)"
        case .hwinuse:
            return "Hardware already in use by a Net"
        case .netinuse:
            return "A Client is already connected to the Net"
        case .illhw:
            return "Hardware handle is invalid"
        case .illnet:
            return "Net handle is invalid"
        case .illclient:
            return "Client handle is invalid"
        case .illhandle:
            return "Mask for all handle errors"
        case .resource:
            return "Resource (FIFO, Client, timeout) cannot be created"
        case .illparamtype:
            return "Invalid parameter"
        case .illparamval:
            return "Invalid parameter value"
        case .unknown:
            return "Unknown error"
        case .illdata:
            return "Invalid data, function, or action"
        case .illmode:
            return "Driver object state is wrong for the attempted operation"
        case .caution:
            return "An operation was successfully carried out, however, irregularities were registered"
        case .initialize:
            return "Channel is not initialized"
        case .illoperation:
            return "Invalid operation"
        }
    }
}

extension CANStatus: RawRepresentable {
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
    
    /// The RawValue of the status. These values link back to the original C values found in `PCBUSB.h`
    var rawValue: UInt32 {
        switch self {
        case .ok:
            return PCAN_ERROR_OK
        case .xmtfull:
            return PCAN_ERROR_XMTFULL
        case .overrun:
            return PCAN_ERROR_OVERRUN
        case .buslight:
            return PCAN_ERROR_BUSLIGHT
        case .busheavy:
            return PCAN_ERROR_BUSHEAVY
        case .buswarning:
            return PCAN_ERROR_BUSWARNING
        case .buspassive:
            return PCAN_ERROR_BUSPASSIVE
        case .busoff:
            return PCAN_ERROR_BUSOFF
        case .anybuserr:
            return (PCAN_ERROR_BUSWARNING | PCAN_ERROR_BUSLIGHT | PCAN_ERROR_BUSHEAVY | PCAN_ERROR_BUSOFF | PCAN_ERROR_BUSPASSIVE)
        case .qrcvempty:
            return PCAN_ERROR_QRCVEMPTY
        case .qoverrun:
            return PCAN_ERROR_QOVERRUN
        case .qxmtfull:
            return PCAN_ERROR_QXMTFULL
        case .regtest:
            return PCAN_ERROR_REGTEST
        case .nodriver:
            return PCAN_ERROR_NODRIVER
        case .hwinuse:
            return PCAN_ERROR_HWINUSE
        case .netinuse:
            return PCAN_ERROR_NETINUSE
        case .illhw:
            return PCAN_ERROR_ILLHW
        case .illnet:
            return PCAN_ERROR_ILLNET
        case .illclient:
            return PCAN_ERROR_ILLCLIENT
        case .illhandle:
            return (PCAN_ERROR_ILLHW | PCAN_ERROR_ILLNET | PCAN_ERROR_ILLCLIENT)
        case .resource:
            return PCAN_ERROR_RESOURCE
        case .illparamtype:
            return PCAN_ERROR_ILLPARAMTYPE
        case .illparamval:
            return PCAN_ERROR_ILLPARAMVAL
        case .unknown:
            return PCAN_ERROR_UNKNOWN
        case .illdata:
            return PCAN_ERROR_ILLDATA
        case .illmode:
            return PCAN_ERROR_ILLMODE
        case .caution:
            return PCAN_ERROR_CAUTION
        case .initialize:
            return PCAN_ERROR_INITIALIZE
        case .illoperation:
            return PCAN_ERROR_ILLOPERATION
        }
    }

}
