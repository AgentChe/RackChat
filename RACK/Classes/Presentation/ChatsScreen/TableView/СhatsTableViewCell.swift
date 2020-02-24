//
//  СhatsTableViewCell.swift
//  RACK
//
//  Created by Алексей Петров on 13/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import AlamofireImage

class ChatsTableViewCell: UITableViewCell {
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var unreadCountView: UIView!
    @IBOutlet weak var userPicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userPicImageView.af_cancelImageRequest()
        userPicImageView.image = nil
        
        lastMessageLabel.text = ""
    }
    
    func bind(chat: AKChat) {
        if let interlocutorAvatarPath = chat.interlocutorAvatarPath,
            let interlocutorAvatarUrl = URL.combain(domain: GlobalDefinitions.ChatService.restDomain, path: interlocutorAvatarPath) {
            userPicImageView.af_setImage(withURL: interlocutorAvatarUrl)
        }
        
        nameLabel.text = chat.interlocutorName
        
        if chat.unreadMessageCount == 0 {
            unreadCountView.isHidden = true
        } else {
            unreadCountView.isHidden =  false
            unreadCountLabel.text = "\(chat.unreadMessageCount)"
        }
        
        if let lastMessage = chat.lastMessage {
            switch lastMessage.type {
            case .image:
                lastMessageLabel.text = "photo".localized
            case .text:
                lastMessageLabel.text = lastMessage.body
            }
        }
    }
}
