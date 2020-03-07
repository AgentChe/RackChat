//
//  SureButtonView.swift
//  RACK
//
//  Created by Алексей Петров on 03/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

final class SureButtonView: UIView {
    @IBOutlet weak var titleLabel: GradientLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.gradientColors = [#colorLiteral(red: 0.9882352941, green: 0.3882352941, blue: 0.4196078431, alpha: 1), #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5725490196, alpha: 1)]
    }
}
