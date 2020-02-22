//
//  UnmatchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

protocol UnmatchViewControllerDelegate: class {
    func wasRepoerted()
}

class UnmatchViewController: UIViewController {
    @IBOutlet weak var userpicImageViw: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    weak var delegate: UnmatchViewControllerDelegate!
    private var userpic: UIImage = UIImage()
    private var message: String = ""
    private var currentChat: ChatItem!
    
    func config(avatar: UIImage, and name: String, chatItem: ChatItem) {
        userpic = avatar
        message = "Your chat history will disappear as if nothing happened."
        currentChat = chatItem
    }
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        super.viewDidLoad()
        
        userpicImageViw.image = userpic
        messageLabel.text = message
    }
    
    @IBAction func tapOnYes(_ sender: Any) {
        ReportManager.shared.unmatch(in: Double(currentChat!.chatID)) { (succses) in
            self.dismiss(animated: true, completion: {
                self.delegate.wasRepoerted()
            })
        }
    }
    
    @IBAction func tapOnNo(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
