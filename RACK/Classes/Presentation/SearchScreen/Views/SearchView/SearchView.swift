//
//  SearchView.swift
//  RACK
//
//  Created by Алексей Петров on 31.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class SearchView: UIView {
    class func instanceFromNib() -> SearchView {
        UINib(nibName: "SearchView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! SearchView
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newSearchButton: GradientButton!
    @IBOutlet weak var newSearch: UIView!
    @IBOutlet weak var subtitleView: UIView!
    @IBOutlet weak var generalLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var user: UserShow?
    private var animateTimer: Timer?
    
    func config(user: UserShow) {
        self.user = user
        
        self.contentView.alpha = 0.0
        activityIndicator.isHidden = false
        
        if let avatar: UIImage = user.avatar {
            self.userImageView.image = avatar
            self.activityIndicator.isHidden = true
            UIView.animate(withDuration: 0.4) {
                self.contentView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.activityIndicator.alpha = 1.0
            }
            userImageView.downloaded(from: user.avatarURL) {
                self.activityIndicator.isHidden = true
                UIView.animate(withDuration: 0.4) {
                    self.contentView.alpha = 1.0
                }
            }
        }
        
        newSearch.alpha = 0.0
        subtitleView.alpha = 0.0
        
        
        animateGeneralLabel()
    }
    
    func animateGeneralLabel() {
        animateTimer?.invalidate()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.generalLabel.text = "Welcome Back, Tommy Johnagin".uppercased()
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.generalLabel.text = "Hold Tight, Looking for Some Action".uppercased()
            }) { _ in
                var points: String = "   "
                self.animateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    if points == "   " {
                        points = ".  "
                    } else if points == ".  "{
                        points = ".. "
                    } else if points == ".. " {
                        points = "..."
                    } else if points == "..." {
                        points = "   "
                    }
                    self.generalLabel.text =  "Hold Tight, Looking for Some Action".uppercased() + points
                }
            }
        }
    }
    
    func startSearch() {
        UIView.animate(withDuration: 0.5) {
            self.newSearch.alpha = 0.0
            self.subtitleView.alpha = 0.0
        }
        
        animateGeneralLabel()
    }
    
    @IBAction func tapOnNewSearch(_ sender: Any) {
        startSearch()
    }
    
    override func removeFromSuperview() {
        animateTimer?.invalidate()
        
        super.removeFromSuperview()
    }
}
