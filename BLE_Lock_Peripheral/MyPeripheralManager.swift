//
//  MyPeripheralManager.swift
//  BLE_Lock_Peripheral
//
//  Created by David Nemec on 20/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var sharedPM:CBPeripheralManager!
    
    private static let MainServiceUUIDString = "62400EDB-ABA5-4FD0-84B2-C508620020B2" //"180D"//"62400EDB-ABA5-4FD0-84B2-C508620020B2"
    
    private static let MainServiceUUIDString2 = "0FE6E44C-1596-49DE-812D-D6E3F66CE49A"
    
    private static let char1 = "CF422553-EECC-41AA-BDE3-5640022E4972"
    private static let char2 = "74FCF601-B18F-472B-9EB7-1A9414185BE7"
    
    
    func startManager() {
        sharedPM = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
    
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("peripheralManagerDidAddService")
        sharedPM.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid], CBAdvertisementDataLocalNameKey: "Loli loli"])
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState")
        
        
        if peripheral.state == CBManagerState.poweredOn {
            let service = CBMutableService(type: CBUUID(string: type(of: self).MainServiceUUIDString), primary: true)
            let char1 = CBMutableCharacteristic(type: CBUUID(string: type(of: self).char1), properties: CBCharacteristicProperties.read , value: nil, permissions: CBAttributePermissions.readable)
            
            service.characteristics = [char1]
            sharedPM.add(service)
            
            let service2 = CBMutableService(type: CBUUID(string: type(of: self).MainServiceUUIDString2), primary: true)
            let char2 = CBMutableCharacteristic(type: CBUUID(string: type(of: self).char1), properties: CBCharacteristicProperties.read , value: nil, permissions: CBAttributePermissions.readable)
            service2.characteristics = [char2]
            sharedPM.add(service2)
            

        }
    
    }
}
