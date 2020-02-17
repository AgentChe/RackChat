//
//  NoConnectionBannerView.swift
//  RACK
//
//  Created by Алексей Петров on 06/10/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class NoConnectionBannerView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "NoConnectionBannerView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
