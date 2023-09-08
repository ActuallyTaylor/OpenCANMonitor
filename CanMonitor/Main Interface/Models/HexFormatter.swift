//
//  HexFormatter.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI

class HexFormatter: Formatter {
    let byteLimit: Int
    let validHexCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")

    init(byteLimit: Int = (.max / 2)) {
        self.byteLimit = byteLimit
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.byteLimit = (.max / 2)
        super.init(coder: coder)
    }
    
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String,
              string.count < byteLimit * 2,
              checkValidHex(string) else {
            return nil
        }
        return string
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        return checkValidHex(partialString)
    }
    
    private func checkValidHex(_ value: String) -> Bool {
        guard let invalidRange = value.rangeOfCharacter(from: validHexCharacters.inverted) else {
            // If there are no invalid ranges return true
            return true
        }
        return invalidRange.isEmpty
    }
}
