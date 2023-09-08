//
//  CANTransmitMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import Foundation

struct CANTransmitMessage: Identifiable {
    let id: Int
    let deviceID: UInt32
    let type: PCANMessageType
    let data: CANMessage.MessageData
    var currentlyTransmitting: Bool
}
