//
//  DKPartnerMessageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

final class InterlocutorTextTableCell: UITableViewCell, ChatTableCell {
    @IBOutlet public weak var messageLabel: UILabel!
    
    func bind(message: Message) {
        messageLabel.text = message.body
    }
}
