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
        self.title = "Peripheral App"
        QLog("viewDidLoad()", onLevel: .info)
        
        view.backgroundColor = .yellow
        
        sendDataButton.setTitle("Send Data", for: UIControlState.normal)
        sendDataButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        sendDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        sendDataButton.addTarget(self, action: #selector(sendData(sender:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(sendDataButton)
        self.sendDataButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(32)
            //make.left.right.equalToSuperview()
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.sendMail(_:)))
        tapAction.numberOfTapsRequired = 7
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapAction)
    }
    
    func sendMail(_ sender: UITapGestureRecognizer){
        if !MFMailComposeViewController.canSendMail(){
            return
        }
        let receipient = "ios@quanti.cz"
        
        let mailController = LogFilesViaMailViewController(withRecipients: [receipient])
        mailController.mailComposeDelegate = self
        mailController.navigationBar.tintColor = UIColor.blue
        self.present(mailController, animated: true, completion: nil)
        
    }
    
    
    func sendData(sender: UIButton!) {
        AppDelegate.shared.bleManager.sendData()
    }

}

extension ViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

