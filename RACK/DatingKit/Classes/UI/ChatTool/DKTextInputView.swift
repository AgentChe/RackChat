//
//  TextInputView.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 21.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

protocol DKTextInputViewDelegate: class {
    func textInputView(_ textInputView: DKTextInputView, change height: CGFloat)
    func textInputView(_ textInputView: DKTextInputView, change value: String)
    func textInputViewDidChange(_ textInputView: DKTextInputView)
}

extension DKTextInputViewDelegate {
    func textInputView(_ textInputView: DKTextInputView, change value: String) {}
    func textInputViewDidChange(_ textInputView: DKTextInputView) {}
}

class DKTextInputView: UIView {
    
    weak var delegate: DKTextInputViewDelegate?
    
    var text: String {
        get {
            return textView.text
        }
        set {
            
            if newValue == "" {
                textView.contentSize.height = textView.font!.lineHeight
                 delegate?.textInputView(self, change: textView.contentSize.height)
            }
            
            textView.text = newValue
        }
    }
    
    var keyboadApperance: UIKeyboardAppearance {
        get {
            return textView.keyboardAppearance
        }
        set {
            textView.keyboardAppearance = newValue
        }
    }
    
    var keyboadType: UIKeyboardType {
        get {
            return textView.keyboardType
        }
        
        set {
            textView.keyboardType = newValue
        }
      }
    
    var placeholderText: String = "" {
        didSet {
            if textView.text.isEmpty {
                placeholder(show: true)
            }
        }
    }
    
    var placeholderTextColor: UIColor = .lightGray {
        didSet {
            if textView.text.isEmpty {
                placeholder(show: true)
            }
        }
    }
    
    var textColor: UIColor = .white {
        didSet {
            textView.textColor = textColor
        }
    }
   
    var contentHeight: CGFloat {
        return textView.contentSize.height
    }
    
    var linesLimit: Int = 3
    
    var font: UIFont! {
        get {
            return textView.font!
        }
        
        set {
            if let newFont: UIFont = newValue {
                textView.font = newFont
            }
        }
    }
    
    var fontSize: CGFloat = 17.0 {
        didSet {
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    private var scrolView: UIScrollView
    private var textView: UITextView
    private var currentLinesCount: Int = 0
    
    override init(frame: CGRect) {
        scrolView = UIScrollView()
        textView = UITextView()
        super.init(frame: frame)
        scrolView.backgroundColor = .clear
        textView.delegate = self
        textView.textColor = textColor
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: fontSize)
        addSubview(scrolView)
        scrolView.addSubview(textView)
    }
    
    required init?(coder: NSCoder) {
        scrolView = UIScrollView()
        textView = UITextView()
        super.init(coder: coder)
        scrolView.backgroundColor = .clear
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        addSubview(scrolView)
        scrolView.addSubview(textView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrolView.frame = self.bounds
        textView.frame = bounds
        scrolView.contentSize = textView.frame.size
        
        if currentLinesCount <= linesLimit {
//            textView.scrollToTop()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    func placeholder(show: Bool) {
        textView.textColor = show ? placeholderTextColor : textColor
        textView.text = placeholderText
    }

}

extension DKTextInputView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderTextColor {
            textView.text = nil
            textView.textColor = textColor
        }
        if textView.text.count == 0 {
            delegate?.textInputView(self, change: textView.contentSize.height)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = placeholderTextColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textInputViewDidChange(self)
        let numLines: CGFloat = (textView.contentSize.height / textView.font!.lineHeight)
        
        let linesCount: Int = Int(numLines)
        if currentLinesCount != linesCount {
            currentLinesCount = linesCount
            
            if linesCount <= linesLimit {
                delegate?.textInputView(self, change: textView.contentSize.height)
            }
        }
        
    }
}

