//
//  DKPartnerMessageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

open class DKPartnerMessageTableViewCell: UITableViewCell {
    
    @IBOutlet public weak var messageLabel: UILabel!
    
    public func config(message: Message) {
        messageLabel.text = message.body
    }
}
