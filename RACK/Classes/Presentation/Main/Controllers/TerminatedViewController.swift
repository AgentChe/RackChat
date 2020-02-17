//
//  TerminatedViewController.swift
//  RACK
//
//  Created by Алексей Петров on 19/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import MessageUI

class TerminatedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapOnLegalEmail(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["legal@rack.today"])
            mail.mailComposeDelegate = self
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    
}

extension TerminatedViewController:  MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
