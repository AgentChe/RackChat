//
//  SizeUtils.swift
//  RACK
//
//  Created by Andrey Chernyshev on 21/02/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import UIKit

final class SizeUtils {
    static func value(largeDevice: CGFloat, smallDevice: CGFloat) -> CGFloat {
        return UIDevice.current.isSmallScreen ? smallDevice : largeDevice
    }
    
    static func value(largeDevice: CGFloat, smallDevice: CGFloat, verySmallDevice: CGFloat) -> CGFloat {
        let device = UIDevice.current
        
        if device.isSmallScreen {
            if device.isVerySmallScreen {
                return verySmallDevice
            }
            
            return smallDevice
        }
        
        return largeDevice
    }
}
