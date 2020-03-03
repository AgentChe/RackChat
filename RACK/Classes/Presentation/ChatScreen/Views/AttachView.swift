//
//  AttachView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 03/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private final class AttachCaseView: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 14, y: 15, width: 32, height: 32))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var label: UILabel = {
        let x: CGFloat = 14 + 32 + 15
        let view = UILabel(frame: CGRect(x: x,
                                         y: 19,
                                         width: self.bounds.width - x - 16,
                                         height: 23))
        view.font = Fonts.SPProText.regular(size: 19)
        view.textColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        
        addSubviews()
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(label)
    }
}

final class AttachView: UIView {
    enum Case {
        case photo
    }
    
    private lazy var photoCaseView: AttachCaseView = {
        let view = AttachCaseView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 60))
        view.imageView.image = UIImage(named: "sendPhoto")
        view.label.text = "photo".localized
        view.label.sizeToFit()
        return view
    }()
    
    private(set) var caseTapped: Signal<Case>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = UIColor(red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 0.6)
        layer.cornerRadius = 12
        
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        addSubview(photoCaseView)
    }
    
    private func addActions() {
        let photoCaseTapGesture = UITapGestureRecognizer()
        photoCaseView.addGestureRecognizer(photoCaseTapGesture)
        
        caseTapped = photoCaseTapGesture.rx.event
            .map { _ in AttachView.Case.photo }
            .asSignal(onErrorSignalWith: .never())
    }
}
