//
//  PeripheralDevices.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 10/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation

protocol PeripheralDevicesDelegate: class {
    func didUpdate(_ peripheralDevices: PeripheralDevices)
}

class PeripheralDevices {
    var dictionary = [Int: PeripheralDevice]()
    weak var delegate: PeripheralDevicesDelegate?
    
    var count: Int {
        get {
            return dictionary.count
        }
    }
    
    func append(_ newElement: PeripheralDevice) {
        self.dictionary[dictionary.count] = newElement
        
        delegate?.didUpdate(self)
    }
    
    func removeValue(on key: Int) {
        self.dictionary.removeValue(forKey: key)
        
        delegate?.didUpdate(self)
    }
    
    subscript(index: Int) -> PeripheralDevice? {
        set {
            self.dictionary[index] = newValue
            
            delegate?.didUpdate(self)
        }
        get {
            return self.dictionary[index]
        }
    }
    
    func find(by name: String?) -> (Int, PeripheralDevice)? {
        if let _name = name {
            return dictionary.first(where: { $0.value.name == _name })
        }
        return nil
    }
    
    
    func keepRefreshing(each timeInterval: TimeInterval = 5.0) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (_) in
            for (key, peripheralDevice) in self.dictionary {
                if !peripheralDevice.isAlive() {
                    self.removeValue(on: key)
                }
            }
        }
    }
    
}
