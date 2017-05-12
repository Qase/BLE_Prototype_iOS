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
import QuantiLogger
//import RxSwift
//import RxBluetoothKit


protocol BluetoothMasterManagerDelegate: class {
    func didDiscover(_ peripheral: CBPeripheral, with advertisementData: [String : Any])
    func didDiscoverServices(of peripheral: CBPeripheral)
    func didUpdate(_ peripheral: CBPeripheral)
    func didDisconnect(_ peripheral: CBPeripheral)
    func didUpdate(_ value: String, forCharacteristic characteristic: CBCharacteristic)
}

protocol BluetoothMasterManagerInterface: class {
    func start()
    func assign(delegate: BluetoothMasterManagerDelegate)
    func connectToPeripheral(withIdentifier identifier: UUID)
    func writeCurrentDateToPeripheral(withIdentifier identifier: UUID)
}

class BluetoothMasterManager: NSObject {

    fileprivate var manager: CBCentralManager?
    fileprivate var peripherals = [UUID: CBPeripheral]()
    fileprivate var writableCharacteristic: CBCharacteristic?
    
    weak var delegate: BluetoothMasterManagerDelegate?
}


// MARK: - BluetoothMasterManagerInterface implementation
extension BluetoothMasterManager: BluetoothMasterManagerInterface {
    func start() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func assign(delegate: BluetoothMasterManagerDelegate) {
        self.delegate = delegate
    }
    
    func connectToPeripheral(withIdentifier identifier: UUID) {
        guard let _peripheral = peripherals[identifier] else {
            QLog("Trying to connect to non existing peripheral.", onLevel: .error)
            return
        }
        
        manager?.connect(_peripheral, options: nil)
    }
    
    func writeCurrentDateToPeripheral(withIdentifier identifier: UUID) {
        guard let _peripheral = peripherals[identifier] else {
            QLog("Trying to write a current date to non existing peripheral.", onLevel: .error)
            return
        }
        
        guard let _message = Date().asString().data(using: .utf8) else {
            QLog("Message could not be converted from Date -> String -> Data.", onLevel: .error)
            return
        }
        
        guard let _writableCharacteristic = writableCharacteristic else {
            QLog("Writable characteristic is not available while trying to write current date to it.", onLevel: .error)
            return
        }
        _peripheral.writeValue(_message, for: _writableCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
}


// MARK: - CBCentralManagerDelegate methods
extension BluetoothMasterManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            QLog("Scanning for peripherals...", onLevel: .info)
            central.scanForPeripherals(withServices: nil, options: nil)//[CBCentralManagerScanOptionAllowDuplicatesKey:true])
        } else {
            QLog("Bluetooth not available.", onLevel: .info)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let _ = peripheral.name else {
            //QLog("Scanned peripheral has no name, thus will not be processed anymore.", onLevel: .info)
            return
        }
        
        let localDeviceName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
//        if device?.contains(ConstantsShared.AdvertisementNameKeyString) == true {
//            manager?.stopScan()
//        }
        
        if let _existingPeripheral = peripherals[peripheral.identifier] {
            QLog("Did update device \(peripheral.name ?? "") (\(localDeviceName ?? "no local name")) with id: \(peripheral.identifier)", onLevel: .info)
            
            delegate?.didUpdate(_existingPeripheral)
        } else {
            QLog("Did find new device: \(peripheral.name ?? "") (\(localDeviceName ?? "no local name")) with id: \(peripheral.identifier)", onLevel: .info)

            peripherals[peripheral.identifier] = peripheral
            peripherals[peripheral.identifier]?.delegate = self
            
            delegate?.didDiscover(peripheral, with: advertisementData)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let _ = peripherals[peripheral.identifier] else {
            QLog("Did connect to unknown peripheral.", onLevel: .error)
            return
        }
        
        QLog("Did connect to peripheral: \(peripheral.name ?? "") with id: \(peripheral.identifier).", onLevel: .info)
        
        peripheral.discoverServices(nil)
    }
}


// MARK: - CBPeripheralDelegate methods
extension BluetoothMasterManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let _ = peripherals[peripheral.identifier] else {
            QLog("Did discover services for unknown peripheral.", onLevel: .error)
            return
        }
        
        QLog("Did discover \(peripheral.services?.count ?? 0) services for peripheral: \(peripheral.name ?? "") with id: \(peripheral.identifier).", onLevel: .info)
        
        delegate?.didDiscoverServices(of: peripheral)

        // Find service with READ characteristic
        if let _readService = peripheral.services?.first(where: { $0.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString) }) {
            QLog("Found READ service: \(_readService).", onLevel: .info)
            
            peripheral.discoverCharacteristics([CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString)], for: _readService)
        }
        
        // Find service with WRITE characteristic
        if let _writeService = peripheral.services?.first(where: { $0.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString2) }) {
            QLog("Found WRITE service: \(_writeService).", onLevel: .info)
            
            peripheral.discoverCharacteristics([CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString2)], for: _writeService)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        QLog("Did disconnect from peripheral: \(peripheral.name ?? "") with id: \(peripheral.identifier).", onLevel: .info)
        delegate?.didDisconnect(peripheral)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // READ characteristic
        if let _characteristic = service.characteristics?.first(where: { $0.uuid == CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString) }) {
            QLog("Found READ characteristic: \(_characteristic).", onLevel: .info)
            peripheral.setNotifyValue(true, for: _characteristic)
        }
        
        // WRITE characteristic
        if let _writeCharacteristic = service.characteristics?.first(where: { $0.uuid == CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString2) }) {
            QLog("Found WRITE characteristic: \(_writeCharacteristic).", onLevel: .info)
            self.writableCharacteristic = _writeCharacteristic
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: ConstantsShared.ServiceCharactericticUUIDString) {
            let value = characteristic.value.map({ (data) -> String in
                return String(data: data, encoding: .utf8) ?? ""
            })
            
            if let _value = value {
                delegate?.didUpdate(_value, forCharacteristic: characteristic)
            }
        }
    }

}










/***********/
/* RxSwift */
/***********/

//class BluetoothMasterManager: NSObject {
//    static let shared = BluetoothMasterManager()
//
//    fileprivate let manager = BluetoothManager(queue: .main)
//    //weak var delegate: BluetoothMasterManagerDelegate?
//
//    var scanningObservable: Observable<ScannedPeripheral>?
//
//    private override init() {
//        super.init()
//    }
//
//    func start() {
//        let v1 = manager.rx_state
//            // Filters only those next elements of Observable<BluetoothState> that are set .poweredOn.
//            .filter { $0 == .poweredOff }
//            .do(onNext: { (bluetoothState) in
//                print("Bluetooth is not available!")
//            })
//
//
//        let v2 = manager.rx_state
//            // Filters only those next elements of Observable<BluetoothState> that are set .poweredOn.
//            .filter { $0 == .poweredOn }
//            // Only prints if bluetooth is available or not.
//            .do(onNext: { (bluetoothState) in
//                print("Bluetooth is available!")
//            })
//            .flatMap { (_) -> Observable<ScannedPeripheral> in
//                self.scanningObservable = self.manager.scanForPeripherals(withServices: [])
//                return self.scanningObservable!
//
//            }
//
//        Observable.from([v1, v2]).flatMap { $0 }.subscribe { (event) in
//            switch event {
//            case .next(let element):
//                print(element)
//            case .error(let error):
//                print(error)
//            case .completed:
//                print("Completed")
//            }
//        }
//    }
//}

