//
//  MainViewController.swift
//  RACK
//
//  Created by Алексей Петров on 02/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class MainNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

}
