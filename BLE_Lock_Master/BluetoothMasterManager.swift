//
//  MasterManager.swift
//  BLE_Lock_Master
//
//  Created by Martin Troup on 28/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation
import BLE_shared
import RxSwift
import RxBluetoothKit

//protocol BluetoothMasterManagerDelegate: class {
//    func didDiscoverPeripheralWith(name deviceName: String)
//}

class BluetoothMasterManager: NSObject {
    static let shared = BluetoothMasterManager()
    
    fileprivate let manager = BluetoothManager(queue: .main)
    //weak var delegate: BluetoothMasterManagerDelegate?
    
    var scanningObservable: Observable<ScannedPeripheral>?
    
    private override init() {
        super.init()
    }
    
    func start() {
        let v1 = manager.rx_state
            // Filters only those next elements of Observable<BluetoothState> that are set .poweredOn.
            .filter { $0 == .poweredOff }
            .do(onNext: { (bluetoothState) in
                print("Bluetooth is not available!")
            }).
            // Waits x seconds for each emitted element, if timeout -> emits error instead. Time ticks on defined scheduler.
            //.timeout(3.0, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
//            .subscribe { (event) in
//                switch event {
//                case .next(let element):
//                    print(element)
//                case .error(let error):
//                    print(error)
//                case .completed:
//                    print("Completed")
//                }
        
        let v2 = manager.rx_state
            // Filters only those next elements of Observable<BluetoothState> that are set .poweredOn.
            .filter { $0 == .poweredOn }
            
            // Only prints if bluetooth is available or not.
            .do(onNext: { (bluetoothState) in
                print("Bluetooth is available!")
            })
            .flatMap { _ in
                self.manager.scanForPeripherals(withServices: [])
//                let scanningObservable = manager.scanForPeripherals(withServices: [])
//                return scanningObservable
            }
            // Waits x seconds for each emitted element, if timeout -> emits error instead. Time ticks on defined scheduler.
            //.timeout(3.0, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
//            .subscribe { (event) in
//                switch event {
//                case .next(let element):
//                    print(element)
//                case .error(let error):
//                    print(error)
//                case .completed:
//                    print("Completed")
//                }
//            }
    
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
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    func start() {
//        manager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    fileprivate var manager: CBCentralManager?
//    fileprivate var peripheral: CBPeripheral?
//}
//
//extension BluetoothMasterManager: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBManagerState.poweredOn {
//            print("Scanning for peripherals...")
//            central.scanForPeripherals(withServices: nil, options: nil)
//        } else {
//            print("Bluetooth not available.")
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
//        
//        print("Found device: \(device?.description ?? "no description").")
//        delegate?.didDiscoverPeripheralWith(name: device?.description ?? "no description")
//        
//        if device?.contains(ConstantsShared.AdvertisementNameKeyString) == true {
//            manager?.stopScan()
//            
//            self.peripheral = peripheral
//            self.peripheral?.delegate = self
//            
//            manager?.connect(peripheral, options: nil)
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("Did connect to peripheral: \(peripheral).")
//        
//        peripheral.discoverServices(nil)
//    }
//}
//
//extension BluetoothMasterManager: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard self.peripheral == peripheral else {
//            return
//        }
//        
//        print("Did discover \(peripheral.services?.count ?? 0) services.")
//    
//        if let _services = peripheral.services {
//            for service in _services {
//                let thisService = service as CBService
//                
//                if thisService.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString) || thisService.uuid == CBUUID(string: ConstantsShared.MainServiceUUIDString2) {
//                    print("Service \(thisService)")
//                
//                    peripheral.discoverCharacteristics(nil, for: thisService)
//                }
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard self.peripheral == peripheral else {
//            return
//        }
//        
//        print("Did discover \(service.characteristics?.count ?? 0) characteristics.")
//        
//        if let _characteristics = service.characteristics {
//            for characteristic in _characteristics {
//                print(characteristic)
//            }
//        }
//    }
}
