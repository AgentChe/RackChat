//
//  ReportViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit


class ReportViewController: UIViewController {
    
    static let reportNotify = Notification.Name("reported")
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var otherReasonTextView: UITextView!
    @IBOutlet weak var otherReasonView: UIView!
    @IBOutlet var processingView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var menuView: UIView!
    private var currentChat: ChatItem?
    
    
    func config(chat: ChatItem) {
        currentChat = chat
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerLabel.text = "What Went Wrong with " + (currentChat?.partnerName)! + "?"
        
        DatingKit.user.show { (user, status) in
            guard user != nil else {return}
            
            let str: String = user?.lookingFor == .guys ? "him." : "her."
            
            self.subtitleLabel.text = "It's anonymous, we won't tell " + str
        }
        
        
        
    }
    
    @IBAction func tapOnOther(_ sender: UIButton) {
        menuView.isHidden = true
        otherReasonView.isHidden = false
        //        otherReasonTextView
        otherReasonTextView.becomeFirstResponder()
    }
    
    @IBAction func tapOnInapproriatePhoto(_ sender: UIButton) {
        menuView.isHidden = true
        processingView.isHidden = false
        ReportManager.shared.report(in: Double(currentChat!.chatID), with: .InappropriatePhotos) { (data) in
            self.processingView.isHidden = true
            NotificationCenter.default.post(name: ReportViewController.reportNotify, object: self, userInfo: nil)
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func tapOnInappropriateMessage(_ sender: UIButton) {
        menuView.isHidden = true
        processingView.isHidden = false
        ReportManager.shared.report(in: Double(currentChat!.chatID), with: .InappropriateMessages) { (data) in
            self.processingView.isHidden = true
            NotificationCenter.default.post(name: ReportViewController.reportNotify, object: self, userInfo: nil)
            self.dismiss(animated: true, completion: nil)
        }
    
    }
    
    @IBAction func tapOnSpam(_ sender: UIButton) {
        menuView.isHidden = true
        processingView.isHidden = false
        ReportManager.shared.report(in: Double(currentChat!.chatID), with: .spam) { (data) in
            self.processingView.isHidden = true
            NotificationCenter.default.post(name: ReportViewController.reportNotify, object: self, userInfo: nil)
            self.dismiss(animated: true, completion: nil)
        }
 
    }
    
    @IBAction func tapOnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOnOtherCancel(_ sender: UIButton) {
        otherReasonView.isHidden = true
        otherReasonTextView.resignFirstResponder()
        menuView.isHidden = false
        
    }
    
    @IBAction func tapOnOtherSend(_ sender: UIButton) {
        otherReasonView.isHidden = true
        processingView.isHidden = false
        otherReasonTextView.resignFirstResponder()
        ReportManager.shared.report(in: Double(currentChat!.chatID), with: .other) { (data) in
            self.processingView.isHidden = true
            NotificationCenter.default.post(name: ReportViewController.reportNotify, object: self, userInfo: nil)
            self.dismiss(animated: true, completion: nil)
        }
   
    }
    
}
