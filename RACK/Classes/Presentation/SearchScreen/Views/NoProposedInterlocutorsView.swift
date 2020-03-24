//
//  NoProposedInterlocutorsView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 24/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NoProposedInterlocutorsView: UIView {
    private lazy var notificationsButton: UIButton = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 14))
            .letterSpacing(-0.4)
            .textAlignment(.center)
            .textColor(.black)
    
        let view = UIButton()
        view.setAttributedTitle("notification_settings".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "head")
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var noNewSomeoneLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var notificationInfoLabel: UILabel = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.regular(size: 17))
            .letterSpacing(-0.4)
            .textColor(.black)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "no_proposed_interlocutors_push_info".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var refreshButton: UIButton = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 17))
            .letterSpacing(-0.4)
            .textAlignment(.center)
            .textColor(.white)
        
        let view = UIButton()
        view.setAttributedTitle("refresh".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 26
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "FC636B")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 17))
            .letterSpacing(-0.4)
            .textAlignment(.center)
            .textColor(.black)
        
        let view = UIButton()
        view.setAttributedTitle("back".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var noNewSomeoneTextAttrs: TextAttributes = {
        TextAttributes()
            .font(Fonts.OpenSans.bold(size: 22))
            .textColor(.black)
            .textAlignment(.center)
    }()
    
    private(set) lazy var refresh: Signal<Void> = refreshButton.rx.tap.asSignal()
    private(set) lazy var back: Signal<Void> = backButton.rx.tap.asSignal()
    private(set) lazy var notificationSettings: Signal<Void> = notificationsButton.rx.tap.asSignal()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(user: User) {
        var whom: String
        
        switch user.lookingFor {
        case .guys:
            whom = "boys".localized
        case .girls:
            whom = "girls".localized
        case .any:
            whom = "people".localized
        case .none:
            whom = ""
        }
        
        noNewSomeoneLabel.attributedText = String(format: "no_new_someone".localized, whom).attributed(with: noNewSomeoneTextAttrs)
    }
    
    private func configure() {
        backgroundColor = .white
        
        addSubviews()
    }
    
    private func addSubviews() {
        addSubview(notificationsButton)
        addSubview(iconView)
        addSubview(noNewSomeoneLabel)
        addSubview(notificationInfoLabel)
        addSubview(refreshButton)
        addSubview(backButton)
        
        notificationsButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        notificationsButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        notificationsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        iconView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: topAnchor, constant: SizeUtils.value(largeDevice: 180, smallDevice: 130)).isActive = true

        noNewSomeoneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SizeUtils.value(largeDevice: 36, smallDevice: 28)).isActive = true
        noNewSomeoneLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: SizeUtils.value(largeDevice: -36, smallDevice: -28)).isActive = true
        noNewSomeoneLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 30).isActive = true

        notificationInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SizeUtils.value(largeDevice: 36, smallDevice: 28)).isActive = true
        notificationInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: SizeUtils.value(largeDevice: -36, smallDevice: -28)).isActive = true
        notificationInfoLabel.topAnchor.constraint(equalTo: noNewSomeoneLabel.bottomAnchor, constant: 30).isActive = true

        refreshButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SizeUtils.value(largeDevice: 36, smallDevice: 28)).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: SizeUtils.value(largeDevice: -36, smallDevice: -28)).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        refreshButton.topAnchor.constraint(equalTo: notificationInfoLabel.bottomAnchor, constant: 30).isActive = true

        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SizeUtils.value(largeDevice: 36, smallDevice: 28)).isActive = true
        backButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: SizeUtils.value(largeDevice: -36, smallDevice: -28)).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        backButton.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 30).isActive = true
    }
}
