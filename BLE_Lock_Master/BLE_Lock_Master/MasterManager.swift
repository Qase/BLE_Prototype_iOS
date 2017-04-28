//
//  MasterManager.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 28/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation
import CoreBluetooth

class MasterManager {
    static let shared = MasterManager()
    
    private init() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private var manager: CBCentralManager
    private var peripheral: CBPeripheral?
}

extension MasterManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? String
        
        print("Found device: \(device).")
        
        if device?.containsString(BEAN_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect to peripheral: \(peripheral).")
        
        peripheral.discoverServices(nil)
    }
}

extension MasterManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Did discover \(peripheral.services?.count) services.")
        
        for service in peripheral.services {
            let thisService = service as CBService
            
            if service.UUID == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Did discover \(service.characteristics?.count) characteristics.")
        for characteristic in service.characteristics {
            print(characteristic)
        }
    }
}
