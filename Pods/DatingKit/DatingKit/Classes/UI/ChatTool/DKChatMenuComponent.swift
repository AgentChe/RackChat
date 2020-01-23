//
//  DKChatMenuComponent.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 24.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class DKChatMenuComponent: UIView {
    
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> DKChatMenuComponent {
        guard let bundleURL = Bundle(for: self.classForCoder()).url(forResource: "DatingKit", withExtension: "bundle") else { return DKChatMenuComponent() }
                   
               let bundle = Bundle(url: bundleURL)
                                        
        return UINib(nibName: String(describing: self), bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! DKChatMenuComponent
    }
    
}
