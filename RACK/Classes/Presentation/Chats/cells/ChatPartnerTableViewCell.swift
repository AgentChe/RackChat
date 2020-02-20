//
//  ChatPartnerTableViewCell.swift
//  FAWN
//
//  Created by Алексей Петров on 04/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import UIKit
import DatingKit

class ChatPartnerTableViewCell: UITableViewCell {
    @IBOutlet var messageLabel: UILabel!
    
    private func configMyMessage(with text: String) {
        messageLabel.text =  text
    }
    
    func configWithState(message: Message) {
        switch message.type {
        case .text:
            configMyMessage(with: message.body)
        case .none:
            break
        case .image:
            break
        }
    }
}
