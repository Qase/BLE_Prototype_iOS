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
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.sendMail(_:)))
        tapAction.numberOfTapsRequired = 7
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapAction)
    }

    func sendMail(_ sender: UITapGestureRecognizer){
        if !MFMailComposeViewController.canSendMail() {
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

