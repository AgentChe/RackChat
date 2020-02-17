//
//  NoView.swift
//  RACK
//
//  Created by Алексей Петров on 01.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit

class NoView: UIView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var newSearchButton: GradientButton!
    @IBOutlet weak var backButton: UIButton!
    
    class func instanceFromNib() -> NoView {
        return UINib(nibName: "NoView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! NoView
    }
    
    func config(match: DKMatch) {
        let genderStr: String = match.matchedUserGender == .man ? "he " : "she "
        let message: String = "Sorry " + genderStr + "said no"
        messageLabel.text = message.uppercased()
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
