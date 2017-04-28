//
//  MasterManager.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 28/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation
import BLE_shared
import CoreBluetooth

class MasterManager: NSObject {
    static let shared = MasterManager()
    
    private override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start() {
        
    }
    
    fileprivate var manager: CBCentralManager?
    fileprivate var peripheral: CBPeripheral?
}

extension MasterManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Scanning for peripherals...")
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
        
        print("Found device: \(device?.description ?? "no description").")
        
        if device?.contains(ConstantsShared.AdvertisementNameKeyString) == true {
            manager?.stopScan()
            
            self.peripheral = peripheral
            self.peripheral?.delegate = self
            
            manager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect to peripheral: \(peripheral).")
        
        peripheral.discoverServices(nil)
    }
}

extension MasterManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard self.peripheral == peripheral else {
            return
        }
        
        print("Did discover \(peripheral.services?.count ?? 0) services.")
    
        if let _services = peripheral.services {
            for service in _services {
                let thisService = service as CBService
                
                if thisService.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString) || thisService.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString2) {
                    print("Service \(thisService)")
                
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard self.peripheral == peripheral else {
            return
        }
        
        print("Did discover \(service.characteristics?.count ?? 0) characteristics.")
        
        if let _characteristics = service.characteristics {
            for characteristic in _characteristics {
                print(characteristic)
            }
        }
    }
}
