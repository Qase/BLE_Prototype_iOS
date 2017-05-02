//
//  ViewController.swift
//  BLE_Lock_Master
//
//  Created by David Nemec on 27/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import SnapKit

struct PeripheralDevice {
    var name: String
    var lastAdvertisation: Date
    
    func isAlive() -> Bool {
        let nowMinus5Mins = Calendar.current.date(byAdding: .minute, value: -5, to: Date())
        return nowMinus5Mins! < lastAdvertisation
    }
}

class DevicesTableViewController: UIViewController {
    fileprivate let tableView = UITableView()
    fileprivate var peripheralDevices = [Int: PeripheralDevice]()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableViewCells.devicesTableViewCell)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        let bluetoothMasterManager = BluetoothMasterManager.shared
        bluetoothMasterManager.delegate = self
        bluetoothMasterManager.start()
    }
}

extension DevicesTableViewController: UITableViewDelegate {
    // TODO
}


extension DevicesTableViewController: UITableViewDataSource {
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCells.devicesTableViewCell, for: indexPath)
        cell.textLabel?.text = peripheralDevices[indexPath.row]!.name
        cell.isHidden = !peripheralDevices[indexPath.row]!.isAlive()
        return cell
    }

    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDevices.count
    }
}

extension DevicesTableViewController: BluetoothMasterManagerDelegate {
    func didDiscoverPeripheralWith(name deviceName: String) {
        if var device = peripheralDevices.first(where: { $1.name == deviceName }) {
            device.value.lastAdvertisation = Date()
            return
        }
        
        peripheralDevices[peripheralDevices.count] = PeripheralDevice(name: deviceName, lastAdvertisation: Date())
        
        tableView.reloadData()
    }
}

