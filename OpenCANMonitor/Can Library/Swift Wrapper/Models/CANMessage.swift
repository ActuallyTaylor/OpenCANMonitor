//
//  CANMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

typealias CAN_DATA = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

/// Stores a CAN Message in  a swift compatible format instead of the auto-generate C struct.
struct CANMessage: Identifiable, Equatable, Hashable, Codable {
    /// The ID of the CAN Message. Normally incremented from 0...total CAN messages.
    let id: Int
    /// The id of the CAN device that this message was received from.
    let deviceID: UInt32
    /// The time at which the message came in. Formatted as (milliseconds:microseconds) from CAN device boot.
    let timestamp: String
    /// The type of the CAN message. See ``PCANMessageType``
    let type: CANMessageType
    /// The data that the message contains.
    let data: MessageData
    
    /// A basic initializer for a ``CANMessage`` that takes all individual parameters.
    /// - Parameters:
    ///   - id: The ID of the can message.
    ///   - deviceID: The ID of the device that the CAN message was received from.
    ///   - timestamp: The timestamp of when the CAN message was received.
    ///   - type: The translated ``PCANMessageType`` of the CAN message.
    ///   - data: The ``MessageData`` of the CAN message.
    init(id: Int, deviceID: UInt32, timestamp: String, type: CANMessageType, data: MessageData) {
        self.id = id
        self.deviceID = deviceID
        self.timestamp = timestamp
        self.type = type
        self.data = data
    }
    
    /// An initializer for a ``CANMessage`` that takes in the C ``TPCANMsg`` and C ``TPCANTimestamp`` that are provided by **PCBUSB Library**
    /// - Parameters:
    ///   - id: The ID of the ``CANMessage``
    ///   - message: The ``TPCANMsg`` that was received from **PCBUSB Library** and will be converted into a ``CANMessage``
    ///   - timestamp: The ``TPCANTimestamp`` that was received from **PCBUSB Library**
    init(id: Int, message: TPCANMsg, timestamp: TPCANTimestamp) {
        self.id = id
        self.deviceID = message.ID
        self.data = MessageData(data: message.DATA)//MessageData(data: swapByteOrder(message.DATA))
        self.timestamp = "\(timestamp.millis):\(timestamp.micros)"
        self.type = CANMessageType(rawValue: UInt32(message.MSGTYPE)) ?? .errFrame
    }
    
    /// Basic conformance to the equatable protocol.
    /// - Parameters:
    ///   - lhs: The first ``CANMessage`` to check against.
    ///   - rhs: The second ``CANMessage`` to check against.
    /// - Returns: If the two ``CANMessage``s match perfectly true will be returned, otherwise false will be returned.
    static func == (lhs: CANMessage, rhs: CANMessage) -> Bool {
        return lhs.id == rhs.id &&
        lhs.deviceID == rhs.deviceID &&
        lhs.timestamp == rhs.timestamp &&
        lhs.type == rhs.type &&
        lhs.data == rhs.data
    }
    
    /// Basic conformance to the hashable protocol.
    /// - Parameter hasher: the `Hasher` to hash into
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.deviceID)
        hasher.combine(self.data.description)
        hasher.combine(self.timestamp)
        hasher.combine(self.type)
    }
}
