//
//  DKMenuCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 24.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

public class DKMenuCell: UIView {

    @IBOutlet public weak var bottomConstrait: NSLayoutConstraint?
    @IBOutlet public weak var height: NSLayoutConstraint?
    @IBOutlet public weak var widght: NSLayoutConstraint?
    @IBOutlet public weak var menu:DKChatMenuView?
    
    public func showMenu(_ show: Bool) {
        
        bottomConstrait?.constant = show ? 8.0 : -34.0
        height?.constant = show ? 58.0 : 0.0
        widght?.constant = show ? 260.0 : 0.0
        
        if show == true {
            self.isHidden = false
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.menu?.alpha = show ? 1.0 : 0.0
        }) { (_) in
            if show == false {
                self.isHidden = true
            }
        }
        
    }


}


extension DKMenuCell: MenuViewProtocol {
    
    public func show(_ show: Bool) {
        showMenu(show)
    }

}
