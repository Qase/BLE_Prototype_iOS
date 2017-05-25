//
//  ViewController.swift
//  BLE_Lock_Peripheral
//
//  Created by David Nemec on 20/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import SnapKit
import MessageUI
import QuantiLogger

class ViewController: UIViewController {

    var sendDataButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QLog("viewDidLoad()", onLevel: .info)
        
        self.title = "Peripheral App"
        
        view.backgroundColor = .white
        
        let customView = UIView()
        customView.backgroundColor = .white
        view.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
        }
        
        
        let vStackView = UIStackView()
        vStackView.axis = .vertical
        vStackView.alignment = .center
        vStackView.spacing = 10.0
        
        customView.addSubview(vStackView)
        vStackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10.0)
        }
        
//        sendDataButton.setTitle("Send Data", for: .normal)
//        sendDataButton.setTitle("Bluetooth peripheral", for: .normal)
//        sendDataButton.setTitleColor(UIColor.black, for: .normal)
//        sendDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
//        sendDataButton.addTarget(self, action: #selector(sendData(sender:)), for: UIControlEvents.touchUpInside)
//        vStackView.addArrangedSubview(sendDataButton)
        
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Put app to the background!"
        descriptionLabel.font = UIFont.italicSystemFont(ofSize: 18.0)
        
        vStackView.addArrangedSubview(descriptionLabel)
        
        setupLogAction()
    }
    
    func sendData(sender: UIButton!) {
        AppDelegate.shared.bleManager.sendData()
    }

}


