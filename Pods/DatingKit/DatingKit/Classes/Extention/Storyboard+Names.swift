//
//  Storyboard+Names.swift
//  FAWN
//
//  Created by Алексей Петров on 16/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import UIKit


    public enum storyboardName: String {
    case registration = "Registration"
    case onboarding = "Onboarding"
}


    public extension UIStoryboard {
        static var registration: UIStoryboard {
        return UIStoryboard(name: storyboardName.registration.rawValue, bundle: Bundle.main)
    }
    
    
        static var onboarding: UIStoryboard {
        return UIStoryboard(name: storyboardName.onboarding.rawValue, bundle: Bundle.main)
    }
}
