//
//  SearchView.swift
//  RACK
//
//  Created by Алексей Петров on 31.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

final class SearchView: UIView {
    class func instanceFromNib() -> SearchView {
        UINib(nibName: "SearchView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! SearchView
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var generalLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var contentView: UIStackView!
    
    private var user: UserShow?
    private var animateTimer: Timer?
    
    override func removeFromSuperview() {
        animateTimer?.invalidate()
        
        super.removeFromSuperview()
    }
    
    func setup(user: UserShow) {
        self.user = user
        
        contentView.alpha = 0.0
        activityIndicator.isHidden = false
        
        if let avatar = user.avatar {
            userImageView.image = avatar
            activityIndicator.isHidden = true
            
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.contentView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.activityIndicator.alpha = 1.0
            }
            
            userImageView.downloaded(from: user.avatarURL) { [weak self] in
                self?.activityIndicator.isHidden = true
                
                UIView.animate(withDuration: 0.4) {
                    self?.contentView.alpha = 1.0
                }
            }
        }
        
        animateGeneralLabel()
    }
    
    private func animateGeneralLabel() {
        animateTimer?.invalidate()
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.generalLabel.text = "Welcome Back, Tommy Johnagin".uppercased()
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.3, animations: {
                self?.generalLabel.text = "Hold Tight, Looking for Some Action".uppercased()
            }, completion: { _ in
                var points: String = "   "
                
                self?.animateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    if points == "   " {
                        points = ".  "
                    } else if points == ".  "{
                        points = ".. "
                    } else if points == ".. " {
                        points = "..."
                    } else if points == "..." {
                        points = "   "
                    }
                    
                    self?.generalLabel.text =  "Hold Tight, Looking for Some Action".uppercased() + points
                }
            })
        })
    }
}
