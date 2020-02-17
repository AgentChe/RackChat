//
//  NoOneHereView.swift
//  RACK
//
//  Created by Алексей Петров on 02.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

enum NoOneHereSceneType {
    case withRequest
    case withOutReuest
}

class NoOneHereView: UIView {
    
    class func instanceFromNib() -> NoOneHereView {
        return UINib(nibName: "NoOneHereView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! NoOneHereView
    }

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var sureButton: GradientButton!
    @IBOutlet weak var withReuest: UIStackView!
    @IBOutlet weak var withoutRequest: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newSearch: GradientButton!
    
    
    func config() {
        withReuest.isHidden = true
        withReuest.alpha = 0.0
        withoutRequest.isHidden = true
        withoutRequest.alpha = 0.0
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications == false {
            withReuest.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.withReuest.alpha = 1.0
            }
        } else {
            self.withoutRequest.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.withoutRequest.alpha = 1.0
            }
        }
                            
    }
    
    func showSearchView() {
        withReuest.isHidden = true
        self.withoutRequest.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.withoutRequest.alpha = 1.0
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
