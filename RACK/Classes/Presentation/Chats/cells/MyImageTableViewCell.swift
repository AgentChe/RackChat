//
//  MyImageTableViewCell.swift
//  FAWN
//
//  Created by Алексей Петров on 04/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import UIKit

protocol MyImageTableViewCellDelegate: class {
    func tapOnError(message: Message, cell: MyImageTableViewCell)
}

class MyImageTableViewCell: UITableViewCell {

    @IBOutlet weak var rightInsert: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var message: Message?
    var sendetImage: UIImage?
    @IBOutlet var myImageView: UIImageView!
    weak var delegate: MyImageTableViewCellDelegate!
    var handler: (_ cell : MyImageTableViewCell) -> Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func acrivateCell() {
        activityIndicator.isHidden = false
    }
    
    func stopAcrivateCell() {
           activityIndicator.isHidden = true
       }
    
    func configWith(message: Message) {
        activityIndicator.isHidden = true
        self.message = message
        myImageView.alpha = 0.0
        if message.sendetImage != nil {
            myImageView.image = message.sendetImage
            
        } else {
            if message.body != "" {
                let url: NSString = message.body as NSString
                let urlString: NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                myImageView.af_setImage(withURL: URL(string: urlString as String)!)
                UIView.animate(withDuration: 0.4) {
                    self.myImageView.alpha = 1.0
                }
            } else {
                
            }
        }
        UIView.animate(withDuration: 0.4) {
            self.myImageView.alpha = 1.0
        }
        
//        if message.messageID == 0 {
//            if message.sendet == false {
//                activityIndicator.isHidden = true
//                showError()
//            } else {
//                rightInsert.constant = 16.0
//               
//                self.layoutIfNeeded()
//                
//            }
//        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapOnRecent(_ sender: Any) {
        handler(self)
     
    }
    
    func showError() {
        rightInsert.constant = 56.0
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
        }
    }
    
    func send(image: UIImage, with newMessage:Message, completion: @escaping (_ message: Message) -> Void) {
        
        self.message = newMessage
        self.sendetImage = image
//        ChatsManager.shared.send(image: image, with: newMessage, in: ChatsManager.shared.currentChat.chatID) { (succses, message) in
//            self.activityIndicator.isHidden = true
//
//            if !succses {
//                self.showError()
//                
//            } else {
//                completion(message!)
//            }
//        }
    }
    
    override func prepareForReuse() {
        myImageView.image = nil
        rightInsert.constant = 16.0
        self.layoutIfNeeded()
        activityIndicator.isHidden = true
    }
}
