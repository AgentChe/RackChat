//
//  SearchView.swift
//  RACK
//
//  Created by Алексей Петров on 31.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Kingfisher

final class SearchView: UIView {
    class func instanceFromNib() -> SearchView {
        UINib(nibName: "SearchView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! SearchView
    }
    
    @IBOutlet private weak var generalLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var contentView: UIStackView!
    
    private var user: User?
    private var animateTimer: Timer?
    
    override func removeFromSuperview() {
        animateTimer?.invalidate()
        
        super.removeFromSuperview()
    }
    
    func setup(user: User) {
        self.user = user
        
        contentView.alpha = 0.0
        
        if let avatarUrl = user.avatarURL {
            userImageView.kf.indicatorType = .activity
            userImageView.kf.setImage(with: avatarUrl) { [weak self] _ in
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
