//
//  UnmatchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit

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
        message = "Your chat history will disappear as if nothing happened." //  "You’ll never see \(name) ever again." //You'll never see 'NAME' ever again.
        currentChat = chatItem
    }
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        super.viewDidLoad()
        userpicImageViw.image = userpic
        messageLabel.text = message
        // Do any additional setup after loading the view.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
