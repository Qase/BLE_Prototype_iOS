//
//  ViewController.swift
//  BLE_Lock_Peripheral
//
//  Created by David Nemec on 20/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var sendDataButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        view.snp.makeConstraints { (make) in
            make.height.equalTo(self.view.snp.height)
        }
        
        sendDataButton.setTitle("Send Data", for: UIControlState.normal)
        sendDataButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        sendDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        sendDataButton.addTarget(self, action: #selector(sendData(sender:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(sendDataButton)
        self.sendDataButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
        }
    }
    
    
    func sendData(sender: UIButton!) {
        AppDelegate.shared.bleManager.sendData()
    }

}

