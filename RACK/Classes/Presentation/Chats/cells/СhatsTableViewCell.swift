//
//  СhatsTableViewCell.swift
//  RACK
//
//  Created by Алексей Петров on 13/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import AlamofireImage

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var unreadCountView: UIView!
    @IBOutlet weak var userPicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(item: ChatItem) {
        
        userPicImageView.af_setImage(withURL: URL(string: item.partnerAvatarString)!)
        
        nameLabel.text = item.partnerName
        if item.unreadCount == 0 {
            unreadCountView.isHidden = true
        } else {
            unreadCountView.isHidden =  false
            unreadCountLabel.text = "\(item.unreadCount)"
        }
        
        switch item.lastMessageType {
        case .image:
            lastMessageLabel.text = "image"
            break
        case .text:
             lastMessageLabel.text = item.lastMessageBody
            break
        case .none:
            lastMessageLabel.text = "no messages yet."
            break
        }
    }
    
    override func prepareForReuse() {
        self.userPicImageView.image = UIImage()
    }
    
}
