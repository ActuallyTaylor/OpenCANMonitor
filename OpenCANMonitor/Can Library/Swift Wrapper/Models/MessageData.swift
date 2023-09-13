//
//  MessageData.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/13/23.
//

import Foundation

/// A struct for containing CAN message data.
struct MessageData: Codable, CustomStringConvertible, Equatable {
    let byte0: UInt8
    let byte1: UInt8
    let byte2: UInt8
    let byte3: UInt8
    let byte4: UInt8
    let byte5: UInt8
    let byte6: UInt8
    let byte7: UInt8
    
    /// An initializer that takes in all of the bytes in a CAN message, one at a time.
    /// - Parameters:
    ///   - byte0: The first byte of data
    ///   - byte1: The second byte of data
    ///   - byte2: The third byte of data
    ///   - byte3: The fourth byte of data
    ///   - byte4: The fifth byte of data
    ///   - byte5: The sixth byte of data
    ///   - byte6: The seventh byte of data
    ///   - byte7: The eighth byte of data
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
    
    /// An initializer that takes a Tuple of 8 bytes and converts them into the individually stored bytes in this struct.
    /// - Parameter data: A tuple of 8 data bytes.
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
    
    /// A variable that returns the MessageData as a Tuple of 8 bytes.
    var tuple: CAN_DATA {
        (byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
    }
    
    /// A variable that returns the MessageData as an Array of 8 bytes.
    var array: [UInt8] {
        [byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7]
    }
    
    /// The description of the string, provided as 8 hex bytes.
    var description: String {
        return String(format: "%02X %02X %02X %02X %02X %02X %02X %02X", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
    }
    
    /// An ASCII representation of the bytes as 8 C characters.
    var ascii: String {
        return String(format: "%c %c %c %c %c %c %c %c", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
    }
    
    /// The decimal representation of the 8 bytes.
    var decimal: String {
        return String(format: "%d %d %d %d %d %d %d %d", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
    }
    
    /// A connivence function for detecting if the MessageData fits the provided Hex String.
    /// - Parameter hexString: The string of hex characters to check against.
    /// - Returns: If the hex data contains the string of hex characters provided.
    func containsHex(_ hexString: String) -> Bool {
        // Remove all of the spaces from our formatting to just get a series of hex values
        let formattedData = String(format:"%02X%02X%02X%02X%02X%02X%02X%02X", byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        
        var hexString = hexString
        hexString.removeAll { c in
            return c.isWhitespace
        }
        
        return formattedData.contains(hexString)
    }
    
    /// A basic conformance to the equatable protocol.
    /// - Parameters:
    ///   - lhs: The first ``MessageData`` to check against.
    ///   - rhs: The second ``MessageData`` to check against.
    /// - Returns: If the two message datas are exactly the same it will return true.
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

