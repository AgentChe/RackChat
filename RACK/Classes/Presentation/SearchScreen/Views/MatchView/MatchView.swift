//
//  MatchView.swift
//  RACK
//
//  Created by Алексей Петров on 01.11.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Kingfisher

class MatchView: UIView {
    class func instanceFromNib() -> MatchView {
        UINib(nibName: "MatchView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! MatchView
    }
    
    @IBOutlet private weak var patrnerCenter: NSLayoutConstraint!
    @IBOutlet private weak var userCenter: NSLayoutConstraint!
    @IBOutlet private weak var buttonsHeight: NSLayoutConstraint!
    @IBOutlet private weak var partnerImgHeight: NSLayoutConstraint!
    @IBOutlet private weak var partnerImgWidth: NSLayoutConstraint!
    
    @IBOutlet private weak var waitingView: UIView!
    @IBOutlet private weak var buttonsView: UIStackView!
    @IBOutlet private weak var secondNameLabel: UILabel!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var nameBundle: UIStackView!
    @IBOutlet private weak var skipButton: UIButton!
    @IBOutlet private weak var sureButton: UIButton!
    @IBOutlet private weak var skipButtonView: SkipButtonView!
    @IBOutlet private weak var sureButtonView: SureButtonView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var partnerImageView: UIImageView!
    @IBOutlet private weak var userImageView: UIImageView!
    
    var onSure: (() -> ())?
    var onSkip: (() -> ())?
    
    func setup(proposedInterlocutor: ProposedInterlocutor, user: UserShow) {
        contentView.alpha = 0.0
        
        let nameSplit = proposedInterlocutor.interlocutorFullName.uppercased().split(separator: " ")
        firstNameLabel.text = String(nameSplit.first ?? "")
        secondNameLabel.text = String(nameSplit.last ?? "")
        
        let myMatchingAvatarPlaceholderImage = user.gender == .man ? #imageLiteral(resourceName: "manPlace") : #imageLiteral(resourceName: "womanPlace")
        if let myMatchingAvatarUrl = URL(string: user.matchingAvatarURL) {
            userImageView.kf.setImage(with: myMatchingAvatarUrl, placeholder: myMatchingAvatarPlaceholderImage)
        } else {
            userImageView.image = myMatchingAvatarPlaceholderImage
        }
        
        let intercolutorMatchingAvatarPlaceholderImage = proposedInterlocutor.gender == .man ? #imageLiteral(resourceName: "manPlace") : #imageLiteral(resourceName: "womanPlace")
        if let interlocutorMatchingAvatarUrl = proposedInterlocutor.interlocutorAvatarUrl {
            partnerImageView.kf.setImage(with: interlocutorMatchingAvatarUrl, placeholder: intercolutorMatchingAvatarPlaceholderImage)
        } else {
            partnerImageView.image = intercolutorMatchingAvatarPlaceholderImage
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.contentView.alpha = 1.0
            self?.partnerImageView.alpha = 1.0
            self?.userImageView.alpha = 1.0
        }
        
        buttonsHeight.constant = 180.0
        
        UIView.animate(withDuration: 0.7, animations: { [weak self] in
             self?.contentView.layoutIfNeeded()
        }, completion: { [weak self] _ in
             self?.startPartnerAnimation()
        })
    }
    
    func waitForPatnerAnimation() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.buttonsView.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.buttonsView.isHidden = true
            self?.waitingView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self?.waitingView.alpha = 1.0
            }
        })
        
        startWaitingAnimation()
    }
    
    @IBAction private func startTapOnSure(_ sender: Any) {
        sureButtonView.alpha = 0.6
        skipButton.isEnabled = false
    }
    
    @IBAction private func tapOnSure(_ sender: Any) {
        sureButtonView.alpha = 1.0
        skipButton.isEnabled = true
        
        onSure?()
    }
    
    @IBAction private func startTapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 0.6
        sureButton.isEnabled = false
    }
    
    @IBAction private func tapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
        
        onSkip?()
    }
    
    private func startPartnerAnimation() {
        patrnerCenter.constant = -95
        userCenter.constant = 105
        
        UIView.animate(withDuration: 25.0) { [weak self] in
            self?.contentView.layoutIfNeeded()
        }
    }
    
    private func startWaitingAnimation() {
        patrnerCenter.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.userImageView.alpha = 0.0
            self?.nameBundle.alpha = 0.0
            self?.contentView.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.partnerImgWidth.constant = 445
            self?.partnerImgHeight.constant = 441
            
            UIView.animate(withDuration: 25) {
                self?.contentView.layoutIfNeeded()
            }
        })
    }
}
