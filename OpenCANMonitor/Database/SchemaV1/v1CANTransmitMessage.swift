//
//  CANTransmitMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import Foundation
import HydrogenReporter
import SwiftData

extension SchemaV1 {
    /// A message that will be transmitted across the CAN network.
    @Model
    class CANTransmitMessage: Identifiable {
        /// A UUID representing the message.
        var id: UUID = UUID()
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
        /// Should the message currently be transmitting?
        var currentlyTransmitting: Bool
        
        /// An initializer that takes in all of the parameters one at a time
        /// - Parameters:
        ///   - id: An optional parameter for the message ID.
        ///   - deviceID: The CAN device ID  for the transmit message.
        ///   - type: The type of the transmit message.
        ///   - data: The data of the transmit message.
        ///   - length: The length of the `data`.
        ///   - cycleTime: How many milliseconds between transmit cycles.
        ///   - currentlyTransmitting: Should the message be currently transmitting?
        init(id: UUID = UUID(), deviceID: UInt32, type: CANMessageType, data: MessageData, length: Int, cycleTime: Int, currentlyTransmitting: Bool) {
            self.id = id
            self.deviceID = deviceID
            self.type = type
            self.data = data
            self.length = length
            self.cycleTime = cycleTime
            self.currentlyTransmitting = currentlyTransmitting
        }
    }
}
