//
//  UIFont+Ext.swift
//  RACK
//
//  Created by Alexey Prazhenik on 2/10/20.
//  Copyright © 2020 AlteqLab LLC. All rights reserved.
//

import UIKit

extension UIFont {
    
    var smaller: UIFont {
        let smallerSize = self.pointSize * 0.8
        return self.withSize(smallerSize)
    }
    
    var properForDevice: UIFont {
        if UIDevice.current.small {
            return smaller
        } else {
            return self
        }
    }
    
}
