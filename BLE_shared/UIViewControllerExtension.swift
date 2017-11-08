//
//  UIViewControllerExtension.swift
//  BLE_shared
//
//  Created by Martin Troup on 25/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import MessageUI
import QuantiLogger

extension UIViewController {
    public func setupLogAction() {
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.sendMail(_:)))
        tapAction.numberOfTapsRequired = 7
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapAction)
    }
    
    @objc func sendMail(_ sender: UITapGestureRecognizer){
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let receipient = "ios@quanti.cz"
        let mailController = LogFilesViaMailViewController(withRecipients: [receipient])
        mailController.mailComposeDelegate = self
        mailController.navigationBar.tintColor = UIColor.blue
        
        self.present(mailController, animated: true, completion: nil)
    }
}


extension UIViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
