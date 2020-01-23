//
//  ScreenManager+UIVIewController.swift
//  FAWN
//
//  Created by Алексей Петров on 16/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {

    
    public func presentViewController(_ viewController: UIViewController, animated: Bool) {
        self.present(viewController, animated: animated) {
//            ScreenManager.shared.onScreenController = viewController
        }
    }
    
    public func dismis(animated: Bool) {
        self.dismiss(animated: animated) {
//            ScreenManager.shared.onScreenController = nil
        }
    }
    
    public func dismisWithCompletion(animated: Bool, completion: @escaping () -> Void) {
        self.dismiss(animated: animated) {
//            ScreenManager.shared.onScreenController = nil
            completion()
        }
    }
}
