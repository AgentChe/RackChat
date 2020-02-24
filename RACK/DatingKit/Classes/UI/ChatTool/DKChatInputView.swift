//
//  DKChatInputView.swift
//  DatingKit
//
//  Created by Алексей Петров on 19.11.2019.
//

import UIKit

class DKChatInputView: UIView {
    
    class func instanceFromNib() -> DKChatInputView {
        return UINib(nibName: String(describing: self), bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! DKChatInputView
    }
    
    var isClose: Bool = false
    
    var closeOptionsIcon: UIImage?
    
    var optionsIcon: UIImage? {
        didSet {
            iconImageView.image = optionsIcon
        }
    }
    
    var sendIcon: UIImage? {
           didSet {
               sendButtonImage.image = sendIcon
           }
       }
    
    var text: String {
        set {
            inputField.text = newValue
        }
        
        get {
            return inputField.text
        }
        
    }
    
    var containerCornerRadius: Int  {
        get {
            return Int(containerView!.cornerRadius)
        }
        
        set {
            containerView.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBOutlet weak var sendButtonImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textInputHeight: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var leftContainerSize: NSLayoutConstraint!
    @IBOutlet weak var inputField: DKTextInputView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var optionalsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textInputHeight.constant = inputField.contentHeight
    }
    
    @IBAction func tapOnSend(_ sender: Any) {
        sendButtonImage.alpha = 0.6
    }
    
    @IBAction func tapUpOnSend(_ sender: Any) {
        sendButtonImage.alpha = 1.0
    }
    
    @IBAction func tapDownInside(_ sender: Any) {
        sendButtonImage.alpha = 1.0
    }
    
    func closeOptionalButton(_ close: Bool) {
        isClose = close
        if isClose == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.rotate(45)
            }) { (_) in
                self.iconImageView.rotate(-45)
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.image = self.closeOptionsIcon
                    self.isClose = true
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.rotate(-45)
            }) { (_) in
                self.iconImageView.rotate(45)
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.image = self.optionsIcon
                    self.isClose = false
                }
            }
        }
    }
    
    @IBAction func tapOnOptinal(_ sender: UIButton) {
        if isClose == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.rotate(45)
            }) { (_) in
                self.iconImageView.rotate(-45)
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.image = self.closeOptionsIcon
                    self.isClose = true
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.rotate(-45)
            }) { (_) in
                self.iconImageView.rotate(45)
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.image = self.optionsIcon
                    self.isClose = false
                }
            }
        }
    }
    
    override func layoutSubviews() {
        textInputHeight.constant = inputField.contentHeight
        super.layoutSubviews()
    }
    
    func change(inputHeight: CGFloat) {
        textInputHeight.constant = inputHeight
        self.layoutSubviews()
        
    }
    
    func showOptionalButton(_ show: Bool) {
        leftContainerSize.constant = show ? 52 : 8
        optionalsButton.isEnabled = show
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        if isClose == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.rotate(-45)
            }) { (_) in
                self.iconImageView.rotate(45)
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.image = self.optionsIcon
                    self.isClose = false
                }
            }
         }
    }
}
