//
//  ErrorWrapper.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

 import Foundation

struct ErrorWrapper: LocalizedError {
    let internalError: Error
    
    var errorDescription: String? {
        return internalError.localizedDescription
    }
}
