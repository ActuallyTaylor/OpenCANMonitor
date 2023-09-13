//
//  CANMessage.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import Foundation

typealias CAN_DATA = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

struct CANMessage: Identifiable, Equatable, Hashable, Codable {
    struct MessageData: Codable, CustomStringConvertible, Equatable {
        let byte0: UInt8
        let byte1: UInt8
        let byte2: UInt8
        let byte3: UInt8
        let byte4: UInt8
        let byte5: UInt8
        let byte6: UInt8
        let byte7: UInt8
        
        init(byte0: UInt8, byte1: UInt8, byte2: UInt8, byte3: UInt8, byte4: UInt8, byte5: UInt8, byte6: UInt8, byte7: UInt8) {
            self.byte0 = byte0
            self.byte1 = byte1
            self.byte2 = byte2
            self.byte3 = byte3
            self.byte4 = byte4
            self.byte5 = byte5
            self.byte6 = byte6
            self.byte7 = byte7
        }
        
        init(data: CAN_DATA) {
            self.byte0 = data.0
            self.byte1 = data.1
            self.byte2 = data.2
            self.byte3 = data.3
            self.byte4 = data.4
            self.byte5 = data.5
            self.byte6 = data.6
            self.byte7 = data.7
        }
        
        var tuple: CAN_DATA {
            (byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        }
        
        var array: [UInt8] {
            [byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7]
        }
        
        var description: String {
            return String(format: "%02X %02X %02X %02X %02X %02X %02X %02X", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        }
        
        var ascii: String {
            return String(format: "%c %c %c %c %c %c %c %c", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        }
        
        var decimal: String {
            return String(format: "%d %d %d %d %d %d %d %d", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        }

        func containsHex(_ hexString: String) -> Bool {
            // Remove all of the spaces from our formatting to just get a series of hex values
            let formattedData = String(format:"%02X%02X%02X%02X%02X%02X%02X%02X", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
            
            var hexString = hexString
            hexString.removeAll { c in
                return c.isWhitespace
            }
            
            return formattedData.contains(hexString)
        }
        
        static func == (lhs: MessageData, rhs: MessageData) -> Bool {
            return lhs.byte0 == rhs.byte0 &&
            lhs.byte1 == rhs.byte1 &&
            lhs.byte2 == rhs.byte2 &&
            lhs.byte3 == rhs.byte3 &&
            lhs.byte4 == rhs.byte4 &&
            lhs.byte5 == rhs.byte5 &&
            lhs.byte6 == rhs.byte6 &&
            lhs.byte7 == rhs.byte7
        }
    }
    
    let id: Int
    let deviceID: UInt32
    let timestamp: String
    let type: PCANMessageType
    let data: MessageData
    
    init(id: Int, deviceID: UInt32, timestamp: String, type: PCANMessageType, data: MessageData) {
        self.id = id
        self.deviceID = deviceID
        self.timestamp = timestamp
        self.type = type
        self.data = data
    }
    
    init(id: Int, message: TPCANMsg, timestamp: TPCANTimestamp) {
        self.id = id
        self.deviceID = message.ID
        self.data = MessageData(data: message.DATA)//MessageData(data: swapByteOrder(message.DATA))
        self.timestamp = "\(timestamp.millis):\(timestamp.micros)"
        self.type = PCANMessageType(rawValue: UInt32(message.MSGTYPE)) ?? .errFrame
    }
    
    static func == (lhs: CANMessage, rhs: CANMessage) -> Bool {
        return lhs.id == rhs.id &&
        lhs.deviceID == rhs.deviceID &&
        lhs.timestamp == rhs.timestamp &&
        lhs.type == rhs.type &&
        lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

//fileprivate func swapByteOrder(_ data: CAN_DATA) -> CAN_DATA {
//    return (data.1, data.0, data.3, data.2, data.5, data.4, data.7, data.6)
//}
