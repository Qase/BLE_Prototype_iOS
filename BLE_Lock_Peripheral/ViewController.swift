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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        view.snp.makeConstraints { (make) in
            make.height.equalTo(self.view.snp.height)
        }
    }

}

