//
//  ChatTableViewCell.swift
//  FAWN
//
//  Created by Алексей Петров on 10/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import UIKit
import DatingKit

protocol ChatTableViewDelegate: class {
    func tapOnResent(message: Message, cell: ChatTableViewCell)
}

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var interlocutorLabel: UILabel!
    @IBOutlet var rightInsert: NSLayoutConstraint!
    @IBOutlet weak var interlocutorMessageView: UIView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTextLabel: UILabel!
    @IBOutlet weak var myMessageView: UIView!
    
    
    weak var delegate: ChatTableViewDelegate!
    var message: Message!
    var handler: (_ cell:ChatTableViewCell) -> Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func tapOnRepead(_ sender: Any) {
        handler(self)
    }
    
    private func configMyMessage(with text: String) {
        myTextLabel.text =  text
    }
    
    
    func configWithState(message: Message) {
        self.message = message
            switch message.type {
            case .text:
                 configMyMessage(with: message.body)
            case .none:
                break
            case .image:
                break
        }
        if message.messageID == 0 {
            if message.sendet == false {
                showError()
            } else {
                        rightInsert.constant = 16.0
                        UIView.animate(withDuration: 0.4) {
                            self.layoutIfNeeded()
                
                        }
            }
        }
        
    }
    
    func showError() {
        rightInsert.constant = 56.0
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
        }
    }
    
    func configWight(image: UIImage) {
        myImageView.isHidden = false
        myMessageView.isHidden = true
        myImageView.image = image
    }
    
    override func prepareForReuse() {
        myTextLabel.text = ""
        rightInsert.constant = 16.0
        self.layoutIfNeeded()

    }
    
}
