//
//  Controller.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/30/25.
//

import Foundation

@Observable
class DocumentController {
    private(set) var bus: CANBus? = nil
    
    init() {
        
    }
    
    func connect(to interface: USBBus, baudRate: BaudRate) throws (CANStatus) {
        self.bus = try CANBus(bus: interface, baudRate: baudRate)
    }
}
