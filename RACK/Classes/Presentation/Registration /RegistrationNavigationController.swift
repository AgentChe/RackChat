//
//  RegistrationNavigationController.swift
//  RACK
//
//  Created by Алексей Петров on 29/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class RegistrationNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        self.addCustomTransitioning()
    }

}


