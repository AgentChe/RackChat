//
//  DKPartnerMessageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

final class DKPartnerMessageTableViewCell: UITableViewCell {
    @IBOutlet public weak var messageLabel: UILabel!
    
    func bind(message: AKMessage) {
        messageLabel.text = message.body
    }
    
    func config(message: Message) {
        messageLabel.text = message.body
    }
}
