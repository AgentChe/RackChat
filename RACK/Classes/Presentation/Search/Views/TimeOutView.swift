//
//  TimeOutView.swift
//  RACK
//
//  Created by Алексей Петров on 02.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class TimeOutView: UIView {
    
    
    @IBOutlet weak var newSearch: GradientButton!
    
    class func instanceFromNib() -> TimeOutView {
        return UINib(nibName: "TimeOutView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! TimeOutView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}