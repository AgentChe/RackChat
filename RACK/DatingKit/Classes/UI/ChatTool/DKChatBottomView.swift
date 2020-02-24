//
//  DKChatBottomView.swift
//  DatingKit
//
//  Created by Алексей Петров on 20.11.2019.
//

import UIKit

public protocol DKChatBottomViewDelegate: class {
    func chatBottomView(_ chatBottomView: DKChatBottomView, optional isHidden: Bool)
}

 public class DKChatBottomView: UIView {
    
    public var keyboardType: UIKeyboardType = .default {
        didSet {
            main.inputField.keyboadType = keyboardType
        }
    }
    
    public var keyboadAppirance: UIKeyboardAppearance = .dark {
        didSet {
            main.inputField.keyboadApperance = keyboadAppirance
        }
    }
    
    @IBInspectable public var linesLimit: Int {
        set {
            main.inputField.linesLimit = newValue
        }
        
        get {
            return main.inputField.linesLimit
        }
    }
    
    @IBInspectable public var fontSize: CGFloat {
        set {
            main.inputField.fontSize = newValue
        }
        
        get {
            return main.inputField.fontSize
        }
    }
    
    @IBInspectable public var fontColor: UIColor {
        set {
            main.inputField.textColor = newValue
        }
        
        get {
            return main.inputField.textColor
        }
    }
    
    @IBInspectable public var placeholderText: String {
        set {
            main.inputField.placeholderText = newValue
        }
        
        get {
            return main.inputField.placeholderText
        }
    }
    
    @IBInspectable public var placeholderTextColor: UIColor {
        set {
            main.inputField.placeholderTextColor = newValue
        }
        
        get {
            return main.inputField.placeholderTextColor
        }
    }
    
    @IBInspectable public var sendButtonImage: UIImage {
        set {
            main.sendIcon = newValue
        }
        get {
            return main.sendButtonImage.image!
        }
    }
    
    public var sendButton: UIButton {
        return main.sendButton
    }
    
    public var font: UIFont {
        set {
            main.inputField.font = newValue
        }
        
        get {
            return main.inputField.font
        }
    }

    @IBInspectable public var closeIcon: UIImage {
        set {
            main.closeOptionsIcon = newValue
        }
        
        get {
            return main.closeOptionsIcon!
        }
    }
    
    @IBInspectable public var optionalIcon: UIImage {
        set {
            main.optionsIcon = newValue
        }
        get {
            return main.optionsIcon!
        }
    }
    
    @IBInspectable public var inputBackground: UIColor {
        set {
            main.containerView.backgroundColor = newValue
        }
        get {
            return main.containerView.backgroundColor!
        }
    }
    
    public var optionalButton: UIButton {
        return main.optionalsButton
    }
    
    public var text: String {
        get {
           
            return main.inputField.text
        }
        
        set {
            if newValue == "" {
                showSendButton(false)
                main.showOptionalButton(true)
            }
            main.inputField.text = newValue
        }
    }
    
    public weak var delegate: DKChatBottomViewDelegate?
    
    private var main: DKChatInputView
    
    required public init?(coder: NSCoder) {
        main = DKChatInputView.instanceFromNib()
        super.init(coder: coder)
        setup()
    }
    
    override public init(frame: CGRect) {
        main = DKChatInputView.instanceFromNib()
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        self.addSubview(main)
        main.inputField.delegate = self
        showSendButton(false)
    }
    
    private func showSendButton(_ show: Bool) {
        sendButton.isEnabled = show
        UIView.animate(withDuration: 0.2) {
            self.main.sendButtonImage.alpha = show ? 1.0 : 0.0
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        showSendButton(false)

    }
    
    public func showOptional(_ show: Bool) {
        main.closeOptionalButton(!show)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        main.frame = self.bounds
    }
    
}

extension DKChatBottomView: DKTextInputViewDelegate {
    
    func textInputView(_ textInputView: DKTextInputView, change height: CGFloat) {
        main.change(inputHeight: height)
    }
    
    func textInputViewDidChange(_ textInputView: DKTextInputView) {
        showSendButton(textInputView.text.count != 0)
        main.showOptionalButton(textInputView.text.count == 0)
        
        delegate?.chatBottomView(self, optional: textInputView.text.count != 0)
    }
    
}

