//
//  MatchView.swift
//  RACK
//
//  Created by Алексей Петров on 01.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import AlamofireImage

class MatchView: UIView {
    
    class func instanceFromNib() -> MatchView {
        return UINib(nibName: "MatchView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! MatchView
    }
    
    @IBOutlet weak var buttonView: NSLayoutConstraint!
    @IBOutlet weak var patrnerCenter: NSLayoutConstraint!
    @IBOutlet weak var userCenter: NSLayoutConstraint!
    @IBOutlet weak var buttonsHeight: NSLayoutConstraint!
    @IBOutlet weak var partnerImgHeight: NSLayoutConstraint!
    @IBOutlet weak var partnerImgWidth: NSLayoutConstraint!

    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var photosCountLabel: UILabel!
    
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var nameBundle: UIStackView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var skipButtonView: SkipButtonView!
    @IBOutlet weak var sureButtonView: SureButtonView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    private var partnerImageAnimationTimer: Timer?
    
    private var match: DKMatch?
    private var user: UserShow?
    
    func config(match: DKMatch, user: UserShow) {
        
        self.match = match
        let fullName: String = match.matchedUserName.uppercased()
        let split = fullName.split(separator: " ")
        let last = String(split.suffix(1).joined(separator: [" "]))
        self.secondNameLabel.text = " " + last + " · " + "\(match.matchedUserAge)" + "?" + " "
        self.firstNameLabel.text = " " + fullName.components(separatedBy: " ").dropLast().joined(separator: " ") + " "
        self.contentView.alpha = 0.0
        self.userImageView.image = user.gender == .man ? #imageLiteral(resourceName: "manPlace") : #imageLiteral(resourceName: "womanPlace")
        self.partnerImageView.image = match.matchedUserGender == .man ? #imageLiteral(resourceName: "manPlace") : #imageLiteral(resourceName: "womanPlace")
        
        if match.matchedUserPhotosCount == 1 {
            self.photosCountLabel.text = "\(match.matchedUserPhotosCount) PHOTO"
        } else {
            self.photosCountLabel.text = "\(match.matchedUserPhotosCount) PHOTOS"
        }
        
        if let avatar: UIImage = user.matchingAvatar {
            self.userImageView.image = avatar
        } else {
            guard let avaUrl:URL = URL(string: user.matchingAvatarURL) else { return }
            userImageView.af_setImage(withURL: avaUrl)
        }
        guard let partnerAvaUrl: URL = URL(string: match.matchedUserAvatarTransparent) else {
            return
        }
        partnerImageView.af_setImage(withURL: partnerAvaUrl)
        
        
        UIView.animate(withDuration: 0.5) {
            self.contentView.alpha = 1.0
            self.partnerImageView.alpha = 1.0
            self.userImageView.alpha = 1.0
        }
        
        self.buttonsHeight.constant = 180.0
        UIView.animate(withDuration: 0.7, animations: {
             self.contentView.layoutIfNeeded()
        }) { (finish) in
             self.showUI()
        }
       
        self.photosView.layer.cornerRadius = 14.0
        self.photosView.layer.masksToBounds = true
    }
    
    private func showUI() {
        self.startPartnerAnimation()
    }
    
    private func startPartnerAnimation() {
        self.patrnerCenter.constant = -95
        self.userCenter.constant = 105
        UIView.animate(withDuration: 25.0) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    private func startWaitingAnimation() {
        patrnerCenter.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.userImageView.alpha = 0.0
            self.nameBundle.alpha = 0.0
            self.photosView.alpha = 0.0
            self.contentView.layoutIfNeeded()
        }) { (fin) in
            self.partnerImgWidth.constant = 445
            self.partnerImgHeight.constant = 441
            UIView.animate(withDuration: 25) {
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
    func waitForPatnerAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonsView.alpha = 0.0
        }) { (fin) in
            self.buttonsView.isHidden = true
            self.waitingView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.waitingView.alpha = 1.0
            }
        }
        startWaitingAnimation()
    }
    
    func showButtons() {
        self.buttonsView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonsView.alpha = 1.0
            self.waitingView.alpha = 0.0
        }) { (fin) in
            self.waitingView.isHidden = true
        }
    }
    
    @IBAction func startTapOnSure(_ sender: Any) {
           sureButtonView.alpha = 0.6
           skipButton.isEnabled = false
           
       }
    
    @IBAction func startTapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 0.6
        sureButton.isEnabled = false
        
    }
    
     @IBAction func tapOnSure(_ sender: Any) {
        sureButtonView.alpha = 1.0
        skipButton.isEnabled = true
    }
    
    @IBAction func tapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
    }
    
    @IBAction func endTapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
    }
    
    @IBAction func endTapOnSure(_ sender: Any) {
        sureButtonView.alpha = 1.0
        skipButton.isEnabled = true
    }

}
