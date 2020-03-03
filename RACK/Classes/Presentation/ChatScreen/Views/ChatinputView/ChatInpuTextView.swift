//
//  ChatInpuTextView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 01/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private final class PlaceholderTextView: UITextView, UITextViewDelegate {
    private lazy var placeholder = "chat_input_placeholder".localized
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        
        if currentText.isEmpty {
            textView.text = placeholder
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        } else if !currentText.isEmpty && textView.text == placeholder {
            textView.text = nil
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == placeholder {
            let selectRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            if textView.selectedTextRange != selectRange {
                textView.selectedTextRange = selectRange
            }
        }
    }
}

final class ChatInpuTextView: UIView {
    private static let maxLines = 4
    
    private lazy var textView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = true
        view.backgroundColor = .clear
        view.font = Fonts.SPProText.regular(size: 17)
        view.textColor = UIColor(red: 142 / 255, green: 142 / 255, blue: 147 / 255, alpha: 1)
        view.text = "chat_input_placeholder".localized
        view.sizeToFit()
        view.delegate = view
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "send_btn"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false 
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private var currentLinesCount = 1
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if currentLinesCount > 1 && currentLinesCount <= ChatInpuTextView.maxLines {
            textView.setContentOffset(.zero, animated: true)
        }
    }
    
    var tapSend: Signal<Void> {
        button.rx.tap.asSignal()
    }
    
    var text: Observable<String?> {
        textView.rx.text.asObservable()
    }
    
    func set(text: String) {
        textView.text = text
    }
    
    private func configure() {
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        addSubview(textView)
        addSubview(button)
        
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8).isActive = true
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 37)
        textViewHeightConstraint.isActive = true
        
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    private func addActions() {
        textView.rx.text
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                let linesCount = Int(self.textView.contentSize.height / self.textView.font!.lineHeight)
                
                if linesCount != self.currentLinesCount && linesCount <= ChatInpuTextView.maxLines {
                    self.currentLinesCount = linesCount
                    
                    self.textViewHeightConstraint.constant = self.textView.contentSize.height
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        textView.rx.text
            .map { $0?.isEmpty == true || $0 == "chat_input_placeholder".localized }
            .bind(to: button.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
