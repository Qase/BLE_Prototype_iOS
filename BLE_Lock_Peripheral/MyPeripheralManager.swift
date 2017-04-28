//
//  MyPeripheralManager.swift
//  BLE_Lock_Peripheral
//
//  Created by David Nemec on 20/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import CoreBluetooth
import BLE_shared

class MyPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var sharedPM:CBPeripheralManager!
    
    func startManager() {
        sharedPM = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
    
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("peripheralManagerDidAddService")
        sharedPM.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid], CBAdvertisementDataLocalNameKey: ConstantsShared.AdvertisementNameKeyString])
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState")
        
        
        if peripheral.state == CBManagerState.poweredOn {
            let service = CBMutableService(type: CBUUID(string: ConstantsShared.MainServiceUUIDString), primary: true)
            let char1 = CBMutableCharacteristic(type: CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString), properties: CBCharacteristicProperties.read , value: nil, permissions: CBAttributePermissions.readable)
            
            service.characteristics = [char1]
            sharedPM.add(service)
            
            let service2 = CBMutableService(type: CBUUID(string: ConstantsShared.MainServiceUUIDString2), primary: true)
            let char2 = CBMutableCharacteristic(type: CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString2), properties: CBCharacteristicProperties.read , value: nil, permissions: CBAttributePermissions.readable)
            service2.characteristics = [char2]
            sharedPM.add(service2)
            

        }
    
    }
}
