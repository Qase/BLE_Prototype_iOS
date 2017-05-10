//
//  ViewController.swift
//  BLE_Lock_Master
//
//  Created by David Nemec on 27/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import SnapKit
import QuantiLogger
import CoreBluetooth


class DevicesTableViewController: UIViewController {
    fileprivate let tableView = UITableView()
    
    fileprivate var peripheralDevices = [Int: PeripheralDevice]()
    
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DevicesTableViewCell.self, forCellReuseIdentifier: Constants.TableViewCells.devicesTableViewCell)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        let bluetoothMasterManager = BluetoothMasterManager.shared
        bluetoothMasterManager.delegate = self
        bluetoothMasterManager.start()
        
        keepRefreshingPeripheralDevices()
    }
    
    func keepRefreshingPeripheralDevices(every timeInterval: TimeInterval = 15.0) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (_) in
            QLog("Checking availability of peripheral devices", onLevel: .info)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

}


// MARK: - UITableViewDelegate methods
extension DevicesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


// MARK: - UITableViewDataSource methods
extension DevicesTableViewController: UITableViewDataSource {
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCells.devicesTableViewCell, for: indexPath) as! DevicesTableViewCell
        cell.title.text = peripheralDevices[indexPath.row]!.name
        cell.subtitle.text = "Number of services: \(peripheralDevices[indexPath.row]!.numOfServices)"
        cell.lastAdvertisationLabel.text = peripheralDevices[indexPath.row]!.lastAdvertisation.asString()
        cell.isEnabled = peripheralDevices[indexPath.row]!.isAlive()
        return cell
    }

    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDevices.count
    }
}



extension DevicesTableViewController: BluetoothMasterManagerDelegate {
    func didUpdate(_ peripheral: CBPeripheral) {
        guard let (_key, _peripheralDevice) = peripheralDevices.first(where: { $0.value.uuid == peripheral.identifier }) else {
            QLog("didUpdate callback called but the peripheral device is uknown.", onLevel: .error)
            return
        }
        
        let updatedPeripheralDevice = PeripheralDevice(uuid: _peripheralDevice.uuid, name: _peripheralDevice.name, numOfServices: _peripheralDevice.numOfServices, lastAdvertisation: Date())
        peripheralDevices[_key] = updatedPeripheralDevice
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didDiscoverServices(of peripheral: CBPeripheral) {
        guard let (_key, _peripheralDevice) = peripheralDevices.first(where: { $0.value.uuid == peripheral.identifier }) else {
            QLog("didDiscoverServices callback called but the peripheral device is uknown.", onLevel: .error)
            return
        }
        let updatedPeripheralDevice = PeripheralDevice(uuid: _peripheralDevice.uuid, name: _peripheralDevice.name, numOfServices: peripheral.services?.count ?? 0, lastAdvertisation: _peripheralDevice.lastAdvertisation)
        peripheralDevices[_key] = updatedPeripheralDevice
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didDiscover(_ peripheral: CBPeripheral, with advertisementData: [String : Any]) {
        if let _ = peripheralDevices.first(where: { $0.value.uuid == peripheral.identifier }) {
            QLog("didDiscover callback called but the peripheral device has already been discovered before.", onLevel: .error)
            return
        }
        

        let localPeripheralName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
        let fullPeripheralName = localPeripheralName != nil ? "\(peripheral.name!) (\(localPeripheralName!))" : peripheral.name!
        peripheralDevices[peripheralDevices.count] = PeripheralDevice(uuid: peripheral.identifier, name: fullPeripheralName, lastAdvertisation: Date())
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
}
