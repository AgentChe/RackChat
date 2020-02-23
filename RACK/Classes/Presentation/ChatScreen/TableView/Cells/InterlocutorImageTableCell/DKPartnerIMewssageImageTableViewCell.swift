//
//  DKPartnerIMewssageImageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

final class DKPartnerIMewssageImageTableViewCell: UITableViewCell {
    @IBOutlet public var messageImageView: UIImageView!
    
    func bind(message: AKMessage) {
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = nil
        
        if let path = message.body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: path) {
            messageImageView.kf.setImage(with: url)
        }
    }

    func config(message: Message) {
        if let image: UIImage = message.sendetImage {
            messageImageView.image = image
        } else {
            guard let url: URL = URL(string: message.body) else {
                return
            }
            
            messageImageView.af_setImage(withURL: url)
        }
        
    }
}
