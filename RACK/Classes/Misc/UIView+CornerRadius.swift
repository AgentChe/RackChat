//
//  UIView+CornerRadius.swift
//  RACK
//
//  Created by Алексей Петров on 30.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }

}


extension UIView {
    
    enum MaskType: Int {
        case type1
        case type2
        case type3
    }
    
    func applyMask(_ type: MaskType) {
        let mask = CAShapeLayer()
        mask.frame = self.layer.bounds
        mask.path = path(for: type)
        self.layer.mask = mask
    }
    
    func path(for type: MaskType) -> CGPath {
        let width = self.layer.frame.size.width
        let height = self.layer.frame.size.height

        switch type {
        case .type1:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: width * 5/110, y: 0))
            path.addLine(to: CGPoint(x: width * 12/110, y: height * 105/110))
            path.addLine(to: CGPoint(x: width, y: height * 107/110))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width * 5/110, y: 0))
            return path

        case .type2:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: width * 1/110, y: 0))
            path.addLine(to: CGPoint(x: width * 1/110, y: height))
            path.addLine(to: CGPoint(x: width * 101/110, y: height))
            path.addLine(to: CGPoint(x: width * 108/110, y: 0))
            path.addLine(to: CGPoint(x: width * 1/110, y: 0))
            return path

        case .type3:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: width *  8/110, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width * 107/110, y: height))
            path.addLine(to: CGPoint(x: width * 104/110, y: 0))
            path.addLine(to: CGPoint(x: width *  8/110, y: 0))
            return path
        }
    }
    
}
