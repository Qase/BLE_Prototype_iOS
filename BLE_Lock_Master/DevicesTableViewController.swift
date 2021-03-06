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
    //fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let bluetoothMasterManager: BluetoothMasterManagerInterface = BluetoothMasterManager()
    fileprivate var peripheralDevices = [Int: PeripheralDevice]()
    
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DevicesTableViewCell.self, forCellReuseIdentifier: Constants.TableViewCells.devicesTableViewCell)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        bluetoothMasterManager.assign(delegate: self)
        bluetoothMasterManager.start()
        
        setupLogAction()
        
        //refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        //tableView.addSubview(refreshControl)
    }
    
//    dynamic private func refresh() {
//        QLog("Checking availability of peripheral devices.", onLevel: .info)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
//            self.tableView.reloadData()
//            self.refreshControl.endRefreshing()
//        }
//    }

}


// MARK: - UITableViewDelegate methods
extension DevicesTableViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _peripheralDevice = peripheralDevices[indexPath.row] else {
            QLog("Did not find peripheral device that was clicked to connect.", onLevel: .error)
            return
        }
        
        switch _peripheralDevice.status {
        case .connected:
            let alertViewController = UIAlertController(title: "Already connected!", message: "There already exists a connection to the peripheral device.", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertViewController, animated: true, completion: nil)
        case .disconnected:
            bluetoothMasterManager.connectToPeripheral(withIdentifier: _peripheralDevice.identifier)
        }
    }
}


// MARK: - UITableViewDataSource methods
extension DevicesTableViewController: UITableViewDataSource {
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCells.devicesTableViewCell, for: indexPath) as! DevicesTableViewCell
        cell.nameLabel.text = peripheralDevices[indexPath.row]!.name
        cell.statusLabel.text = peripheralDevices[indexPath.row]!.status.rawValue
        cell.statusLabel.textColor = peripheralDevices[indexPath.row]!.status == .connected ? .green : .red
        cell.numOfServicesLabel.text = "Number of services: \(peripheralDevices[indexPath.row]!.numOfServices)"
        cell.lastAdvertisationLabel.text = peripheralDevices[indexPath.row]!.lastAdvertisation.asString()
        //cell.isEnabled = peripheralDevices[indexPath.row]!.isAlive()
        //cell.isUserInteractionEnabled = peripheralDevices[indexPath.row]!.isAlive()
        
        return cell
    }

    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDevices.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let _ = peripheralDevices[indexPath.row] else {
            return []
        }
        
        let sendDateAction = UITableViewRowAction(style: .normal, title: "Send date") { (_, indexPath) in
            guard let _peripheralIdentifier = self.peripheralDevices[indexPath.row]?.identifier else {
                QLog("Trying to send date to peripheral device that is unknown.", onLevel: .error)
                return
            }
            
            guard self.peripheralDevices[indexPath.row]?.status == .connected else {
                let notConnectedAlert = UIAlertController(title: "Device not connected", message: "Data cannot be send to a peripheral device since it is not connected.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.tableView.setEditing(false, animated: true)
                })
                notConnectedAlert.addAction(action)
                self.present(notConnectedAlert, animated: true, completion: nil)
                return
            }
            
            self.bluetoothMasterManager.writeCurrentDateToPeripheral(withIdentifier: _peripheralIdentifier)
            
            let dataSentConfirmation = UIAlertController(title: "Data sent", message: "Current date was written to remote WRITE characteristic of the peripheral device.", preferredStyle: .alert)
            self.present(dataSentConfirmation, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { 
                dataSentConfirmation.dismiss(animated: true, completion: nil)
                self.tableView.setEditing(false, animated: true)
            })
        }
        
        sendDateAction.backgroundColor = .blue
        return [sendDateAction]
    }
}



// MARK: - BluetoothMasterManagerDelegate methods
extension DevicesTableViewController: BluetoothMasterManagerDelegate {
    func didDiscover(_ peripheral: CBPeripheral, withFullName fullName: String, withNumOfServices numOfServices: Int) {
        if let _ = peripheralDevices.first(where: { $0.value.identifier == peripheral.identifier }) {
            QLog("didDiscover callback called but the peripheral device has already been discovered before.", onLevel: .error)
            return
        }
        
        peripheralDevices[peripheralDevices.count] = PeripheralDevice(identifier: peripheral.identifier, name: fullName, numOfServices: numOfServices, lastAdvertisation: Date())
        
        self.tableView.reloadData()
    }
    
    func didUpdate(_ peripheral: CBPeripheral) {
        guard let (_key, _peripheralDevice) = peripheralDevices.first(where: { $0.value.identifier == peripheral.identifier }) else {
            QLog("didUpdate callback called but the peripheral device is uknown.", onLevel: .error)
            return
        }
        
        let updatedPeripheralDevice = PeripheralDevice(identifier: _peripheralDevice.identifier, name: _peripheralDevice.name,
                                                       status: _peripheralDevice.status, numOfServices: _peripheralDevice.numOfServices, lastAdvertisation: Date())
        peripheralDevices[_key] = updatedPeripheralDevice
        
        self.tableView.reloadData()
    }

    func didDiscoverServices(of peripheral: CBPeripheral) {
        guard let (_key, _peripheralDevice) = peripheralDevices.first(where: { $0.value.identifier == peripheral.identifier }) else {
            QLog("didDiscoverServices callback called but the peripheral device is uknown.", onLevel: .error)
            return
        }
        
        let updatedPeripheralDevice = PeripheralDevice(identifier: _peripheralDevice.identifier, name: _peripheralDevice.name,
                                                       status: .connected, numOfServices: peripheral.services?.count ?? 0, lastAdvertisation: _peripheralDevice.lastAdvertisation)
        peripheralDevices[_key] = updatedPeripheralDevice
        
        self.tableView.reloadData()
    }
    
    func didDisconnect(_ peripheral: CBPeripheral) {
        guard let (_key, _peripheralDevice) = peripheralDevices.first(where: { $0.value.identifier == peripheral.identifier }) else {
            QLog("didDisconnect called but the peripheral device is unknown.", onLevel: .error)
            return
        }
        
        let updatedPeripheralDevice = PeripheralDevice(identifier: _peripheralDevice.identifier, name: _peripheralDevice.name,
                                                       status: .disconnected, numOfServices: peripheral.services?.count ?? 0, lastAdvertisation: _peripheralDevice.lastAdvertisation)
        peripheralDevices[_key] = updatedPeripheralDevice
        
        self.tableView.reloadData()
    }

    func didUpdate(_ value: String, forCharacteristic characteristic: CBCharacteristic) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let alertViewController = UIAlertController(title: "New characteristic value", message: "Received new characteristic's value: \(value)", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }

    
}
