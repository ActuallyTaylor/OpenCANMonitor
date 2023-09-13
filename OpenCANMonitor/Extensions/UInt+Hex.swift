//
//  UInt+Hex.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/13/23.
//

import Foundation

extension UInt32 {
    func hex(length: Int = 3) -> String {
        let format = "%0\(length.description)x"
        return String(format: format, self)
    }
}

extension UInt8 {
    func hex(length: Int = 3) -> String {
        let format = "%0\(length.description)x"
        return String(format: format, self)
    }
}
