//
//  DKUserImageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

final class MyImageTableCell: UITableViewCell, ChatTableCell {
    @IBOutlet var messageImageView: UIImageView!
    
    func bind(message: Message) {
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = nil
        
        if let url = URL(string: message.body) {
            messageImageView.kf.setImage(with: url)
        }
    }
}
