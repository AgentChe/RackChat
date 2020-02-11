//
//  AppDelegate+Root.swift
//  RACK
//
//  Created by Алексей Петров on 28/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}


