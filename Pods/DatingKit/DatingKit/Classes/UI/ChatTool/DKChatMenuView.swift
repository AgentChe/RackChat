//
//  DKChatMenuView.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 24.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

public class DKChatMenuView: UIControl {
    
    @IBInspectable public var selectedColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5) {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable public var title: String = "" {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable public var icon: UIImage = UIImage() {
        didSet {
            updateUI()
        }
    }
    
    private var mainScreen: DKChatMenuComponent
    private var selectLayer: CALayer
    
    required public init?(coder: NSCoder) {
        selectLayer = CALayer()
        mainScreen = DKChatMenuComponent.instanceFromNib()
        super.init(coder: coder)
        setup()
    }
       
    override public init(frame: CGRect) {
        selectLayer = CALayer()
        mainScreen = DKChatMenuComponent.instanceFromNib()
        super.init(frame: frame)
        setup()
    }
    
    private func updateUI() {
        mainScreen.frame = bounds
        selectLayer.frame = layer.bounds
        selectLayer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        mainScreen.titleLabel.text = title
        mainScreen.iconImageView.image = icon
    }
       
    private func setup() {
        self.addSubview(mainScreen)
        layer.addSublayer(selectLayer)
    }
    
    private func touchSelection(_ select: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.selectLayer.backgroundColor = select ? self.selectedColor.cgColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchSelection(true)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchSelection(false)
        if let touch = touches.first {
            let position = touch.location(in: mainScreen)
            if mainScreen.frame.contains(position) {
                self.sendActions(for: .touchUpInside)
            }
        }
    }
   
    
}
