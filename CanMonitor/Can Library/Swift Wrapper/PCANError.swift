//
//  PCANError.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

enum PCANError: CaseIterable, LocalizedError {
    case ok
    case xmtfull
    case overrun
    case buslight
    case busheavy
    case buswarning
    case buspassive
    case busoff
    case anybuserr
    case qrcvempty
    case qoverrun
    case qxmtfull
    case regtest
    case nodriver
    case hwinuse
    case netinuse
    case illhw
    case illnet
    case illclient
    case illhandle
    case resource
    case illparamtype
    case illparamval
    case unknown
    case illdata
    case illmode
    case caution
    case initialize
    case illoperation
    
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
            return "Driver not loaded"
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
            return "Channel is not initialized [Value was changed from 0x40000 to 0x4000000]"
        case .illoperation:
            return "Invalid operation [Value was changed from 0x80000 to 0x8000000]"
        }
    }
}

extension PCANError: RawRepresentable {
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
