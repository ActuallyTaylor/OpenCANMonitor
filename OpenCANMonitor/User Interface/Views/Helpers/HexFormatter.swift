//
//  HexFormatter.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI

class HexFormatter: Formatter {
    let characterLimit: Int
    let validHexCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")

    init(characterLimit: Int = .max) {
        self.characterLimit = characterLimit
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.characterLimit = .max
        super.init(coder: coder)
    }
    
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String,
              string.count <= characterLimit,
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
        return checkValidHex(partialString) && partialString.count <= characterLimit
    }
    
    private func checkValidHex(_ value: String) -> Bool {
        guard let invalidRange = value.rangeOfCharacter(from: validHexCharacters.inverted) else {
            // If there are no invalid ranges return true
            return true
        }
        return invalidRange.isEmpty
    }
}
