//
//  ButtonView.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class ButtonView: GradientView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func config(bundle: Button) {
        titleLabel.text = bundle.title
        subtitleLabel.text = bundle.subTitle
    }
}
