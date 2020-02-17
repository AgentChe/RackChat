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
    
    private func path(for type: MaskType) -> CGPath {
        let width = self.layer.frame.size.width
        let height = self.layer.frame.size.height

        switch type {
        case .type1:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 3, y: height - 2))
            path.addLine(to: CGPoint(x: width - 2, y: height - 1))
            path.addLine(to: CGPoint(x: width - 2, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            return path

        case .type2:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 1, y: 0))
            path.addLine(to: CGPoint(x: 1, y: height))
            path.addLine(to: CGPoint(x: width - 3, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: 1, y: 0))
            return path

        case .type3:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 4, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width - 1, y: 0))
            path.addLine(to: CGPoint(x: 4, y: 0))
            return path
        }
    }
    
}
