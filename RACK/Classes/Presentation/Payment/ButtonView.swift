//
//  ButtonView.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit

class ButtonView: GardientView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func config(bundle: Button) {
        titleLabel.text = bundle.title
        subtitleLabel.text = bundle.subTitle
    }
    
    

    //    @IBAction func startTapOnBuy(_ sender: UIButton) {
//
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
