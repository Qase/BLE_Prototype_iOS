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
import QuantiLogger

class MyPeripheralManager: NSObject {
    var sharedPM: CBPeripheralManager!
    
    var subscribeChar: CBMutableCharacteristic!
    
    func startManager() {
        sharedPM = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
}

extension MyPeripheralManager: CBPeripheralManagerDelegate {

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        QLog("peripheralManagerDidAddService", onLevel: .debug)
        sharedPM.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid], CBAdvertisementDataLocalNameKey: ConstantsShared.AdvertisementNameKeyString])
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        QLog("peripheralManagerDidUpdateState \(peripheral.state)", onLevel: .info)
        
        switch peripheral.state {
        case .poweredOn:
            QLog(" - poweredOn", onLevel: .debug)
        case .poweredOff:
            QLog(" - poweredOff", onLevel: .debug)
        case .resetting:
            QLog(" - resetting", onLevel: .debug)
        case .unauthorized:
            QLog(" - unauthorized", onLevel: .debug)
        case .unknown:
            QLog(" - unknown", onLevel: .debug)
        case .unsupported:
            QLog(" - unsupported", onLevel: .debug)
        }
        
        if peripheral.state == CBManagerState.poweredOn {
            let service = CBMutableService(type: CBUUID(string: ConstantsShared.MainServiceUUIDString), primary: true)
            let char1 = CBMutableCharacteristic(type: CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString), properties: [.notify, .read] , value: nil, permissions: CBAttributePermissions.readable)
            
            subscribeChar = char1
            
            service.characteristics = [char1]
            sharedPM.add(service)
            
            let service2 = CBMutableService(type: CBUUID(string: ConstantsShared.MainServiceUUIDString2), primary: true)
            let char2 = CBMutableCharacteristic(type: CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString2), properties: [.read, .writeWithoutResponse] , value: nil, permissions: CBAttributePermissions.writeable)
            service2.characteristics = [char2]
            sharedPM.add(service2)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        QLog("MyPeripheralManager \(#function) \(peripheral) \(request)", onLevel: .info)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite CBATTRequest: [CBATTRequest]) {
        QLog("MyPeripheralManager \(#function) \(peripheral) \(CBATTRequest)", onLevel: .info)
        
        sendData(additionalMessage: "didReceiveWrite")
        for request in CBATTRequest{
            
            let data = String(data: request.value!, encoding: .utf8)
            QLog(" - Request Value \(data ?? "")", onLevel: .info)
        }
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        QLog("\(#function)", onLevel: .debug)
        sendData(additionalMessage: "didSubscribeToCharacteristic")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        QLog("MyPeripheralManager \(#function)", onLevel: .info)
    }
    
    func sendData(additionalMessage:String = "") {
        let tosendString = "\(additionalMessage) \(Date())"
        let tosend = tosendString.data(using: .utf8)
        QLog("MyPeripheralManager sendData \(tosendString) \(String(describing: tosend))", onLevel: .info)
        sharedPM.updateValue(tosend!, for: subscribeChar, onSubscribedCentrals: nil)
    }
        
    func sendData() {
        let tosendString = "XXX \(Date())"
        let tosend = tosendString.data(using: .utf8)
        QLog("MyPeripheralManager sendData \(tosendString) \(String(describing: tosend))", onLevel: .info)
        sharedPM.updateValue(tosend!, for: subscribeChar, onSubscribedCentrals: nil)
    }

    
}
