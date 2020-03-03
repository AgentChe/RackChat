//
//  ChatinputView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 01/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatInputView: UIView {
    private lazy var attachButton: ChatAttachButton = {
        let view = ChatAttachButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var inputTextView: ChatInpuTextView = {
        let view = ChatInpuTextView()
        view.backgroundColor = UIColor(red: 218 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var attachTapped = attachButton.event.asSignal()
    private(set) lazy var sendTapped = inputTextView.tapSend
    private(set) lazy var text = inputTextView.text
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(attachState: ChatAttachButton.State) {
        attachButton.apply(state: attachState)
    }
    
    func set(text: String) {
        inputTextView.set(text: text)
    }
    
    private func configure() {
        addSubviews()
    }
    
    private func addSubviews() {
        addSubview(attachButton)
        addSubview(inputTextView)
        
        attachButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        attachButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        attachButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        attachButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        inputTextView.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 8).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
}
