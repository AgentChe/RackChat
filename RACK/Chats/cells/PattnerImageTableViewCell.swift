//
//  PattnerImageTableViewCell.swift
//  FAWN
//
//  Created by Алексей Петров on 04/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import UIKit
import DatingKit

class PattnerImageTableViewCell: UITableViewCell {

    @IBOutlet var partnerImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configWith(message: Message) {
        partnerImageView.alpha = 0.0
        let url: NSString = message.body as NSString
        let urlString: NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        partnerImageView.af_setImage(withURL: URL(string: urlString as String)!)
        UIView.animate(withDuration: 0.4) {
            self.partnerImageView.alpha = 1.0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        partnerImageView.image = nil
    }
    
}
