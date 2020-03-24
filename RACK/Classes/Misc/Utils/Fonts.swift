//
//  Fonts.swift
//  RACK
//
//  Created by Andrey Chernyshev on 02/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit

struct Fonts {
    struct SPProText {
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "SFProText-Regular", size: size)!
        }
    }
    
    struct OpenSans {
        static func semibold(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-Semibold", size: size)!
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-ExtraBold", size: size)!
        }
        
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-Bold", size: size)!
        }
    }
}
