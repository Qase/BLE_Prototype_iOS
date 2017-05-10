//
//  PeripheralDevice.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 10/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation

struct PeripheralDevice {
    var uuid: UUID
    var name: String
    var numOfServices: Int
    var lastAdvertisation: Date
    
    init(uuid: UUID, name: String, numOfServices: Int = 0, lastAdvertisation: Date) {
        self.uuid = uuid
        self.name = name
        self.numOfServices = numOfServices
        self.lastAdvertisation = lastAdvertisation
    }
    
    func isAlive() -> Bool {
        let nowMinus5Mins = Calendar.current.date(byAdding: .second, value: -5, to: Date())!
        return nowMinus5Mins < lastAdvertisation
    }
}
