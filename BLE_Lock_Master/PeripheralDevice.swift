//
//  PeripheralDevice.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 10/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation

enum PeripheralDeviceStatus: String {
    case connected = "connected"
    case disconnected = "disconnected"
}

struct PeripheralDevice {
    var identifier: UUID
    var name: String
    var status: PeripheralDeviceStatus
    var numOfServices: Int
    var lastAdvertisation: Date
    
    init(identifier: UUID, name: String, status: PeripheralDeviceStatus = .disconnected, numOfServices: Int = 0, lastAdvertisation: Date) {
        self.identifier = identifier
        self.name = name
        self.status = status
        self.numOfServices = numOfServices
        self.lastAdvertisation = lastAdvertisation
    }
    
    func isAlive() -> Bool {
        let nowMinus5Mins = Calendar.current.date(byAdding: .minute, value: -5, to: Date())!
        return nowMinus5Mins < lastAdvertisation || status == .connected
    }
}
