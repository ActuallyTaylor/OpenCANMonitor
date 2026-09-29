//
//  StoredTransmitMessage.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/28/26.
//

import Foundation
import SwiftData

extension SchemaV1 {
    /// A storable copy of a ``CANTransmitMessage``. ``CANTransmitMessage`` is not saved since it uses types that can not be saved into SwiftData. This makes the interface a little more janky than I would like but it still functions well enough.
    @Model
    class StoredTransmitMessage {
        /// A UUID representing the message.
        @Attribute(.unique) var uuid: UUID
        
        /// The device CAN ID that the message should be sent from.
        var deviceID: UInt32
        
        /// The type of the transmit message. See ``PCANMessageType``.
        var type: CANMessageType
        
        /// The data that is included within the message.
        var data: MessageData
        
        /// The length of the data.
        var length: Int
        
        /// How many cycles (milliseconds) it should take between sending the message
        var cycleTime: Int
        
        /// If the message is set to currently transmit.
        var enabled: Bool
        
        /// The last time the message was transmitted
        var lastTransmitTime: TimeInterval? = nil
        
        init(uuid: UUID, deviceID: UInt32, type: CANMessageType, data: MessageData, length: Int, cycleTime: Int, enabled: Bool, lastTransmitTime: TimeInterval? = nil) {
            self.uuid = uuid
            self.deviceID = deviceID
            self.type = type
            self.data = data
            self.length = length
            self.cycleTime = cycleTime
            self.enabled = enabled
            self.lastTransmitTime = lastTransmitTime
        }
    }
}
