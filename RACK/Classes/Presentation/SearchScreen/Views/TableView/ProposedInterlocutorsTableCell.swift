//
//  ProposedInterlocutorsTableView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

private final class ActionButton: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var tap = _tap.asSignal()
    private let _tap = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    private func configure() {
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(label)
        
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -24).isActive = true
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    private func addActions() {
        let tapGesture = UITapGestureRecognizer()
        addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?._tap.accept(Void())
            })
            .disposed(by: disposeBag)
    }
}

final class ProposedInterlocutorsTableCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var proposedInterlocutorAvatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var proposedInterlocutorInfoContainerView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var proposedInterlocutorThumbsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dislikeButton: ActionButton = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 20))
            .textAlignment(.center)
            .textColor(UIColor.black.withAlphaComponent(0.5))
        
        let view = ActionButton()
        view.backgroundColor = .white
        view.imageView.image = UIImage(named: "skip_icon")
        view.label.attributedText = "dislike".localized.uppercased().attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeButton: ActionButton = {
        let attrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 20))
            .textAlignment(.center)
            .textColor(UIColor.hexStringToUIColor(hex: "FF6D92"))
        
        let view = ActionButton()
        view.backgroundColor = .white
        view.imageView.image = UIImage(named: "sure_icon")
        view.label.attributedText = "like".localized.uppercased().attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var reportButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.setImage(UIImage(named: "button"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var like: (() -> ())?
    var dislike: (() -> ())?
    var report: (() -> ())?
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(proposedInterlocutor: ProposedInterlocutor) {
        let nameAttrs = TextAttributes()
            .font(Fonts.OpenSans.semibold(size: 32))
            .textColor(.white)
            .backgroundColor(.black)
        
        var info = proposedInterlocutor.interlocutorFullName
        if let age = proposedInterlocutor.age {
            info += " • " + "\(age)"
        }
        
        nameLabel.attributedText = info.uppercased().attributed(with: nameAttrs)
        
        proposedInterlocutorAvatarImageView.kf.cancelDownloadTask()
        if let proposedInterlocutorAvatarUrl = proposedInterlocutor.interlocutorAvatarUrl {
            proposedInterlocutorAvatarImageView.kf.setImage(with: proposedInterlocutorAvatarUrl)
        } else {
            proposedInterlocutorAvatarImageView.image = nil
        }
        
        if let startColor = proposedInterlocutor.startColor {
            proposedInterlocutorInfoContainerView.startColor = UIColor.hexStringToUIColor(hex: startColor)
        }
        
        if let endColor = proposedInterlocutor.endColor {
            proposedInterlocutorInfoContainerView.endColor = UIColor.hexStringToUIColor(hex: endColor)
        }
        
        for thumbImageView in proposedInterlocutorThumbsContainerView.subviews {
            thumbImageView.removeFromSuperview()
        }
        
        var x: CGFloat = 0
        
        for thumbUrl in proposedInterlocutor.interlocutorThumbUrls {
            let container = UIView(frame: CGRect(x: x, y: 0, width: 60, height: 60))
            container.backgroundColor = .black
            
            let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.kf.setImage(with: thumbUrl)
            container.addSubview(imageView)
            
            proposedInterlocutorThumbsContainerView.addSubview(container)
            
            x += 50
        }
    }
    
    private func configure() {
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        contentView.addSubview(proposedInterlocutorInfoContainerView)
        proposedInterlocutorInfoContainerView.addSubview(reportButton)
        proposedInterlocutorInfoContainerView.addSubview(proposedInterlocutorAvatarImageView)
        proposedInterlocutorInfoContainerView.addSubview(nameLabel)
        proposedInterlocutorInfoContainerView.addSubview(proposedInterlocutorThumbsContainerView)
        contentView.addSubview(dislikeButton)
        contentView.addSubview(likeButton)
        
        proposedInterlocutorInfoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        proposedInterlocutorInfoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        proposedInterlocutorInfoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        reportButton.trailingAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.trailingAnchor, constant: -24).isActive = true
        reportButton.topAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.topAnchor, constant: SizeUtils.value(largeDevice: 32, smallDevice: 24)).isActive = true
        reportButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.leadingAnchor, constant: SizeUtils.value(largeDevice: 32, smallDevice: 24)).isActive = true
        nameLabel.topAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.topAnchor, constant: SizeUtils.value(largeDevice: 32, smallDevice: 24)).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.widthAnchor, multiplier: 0.7).isActive = true
        
        proposedInterlocutorThumbsContainerView.leadingAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.leadingAnchor, constant: SizeUtils.value(largeDevice: 32, smallDevice: 24)).isActive = true
        proposedInterlocutorThumbsContainerView.trailingAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.leadingAnchor, constant: SizeUtils.value(largeDevice: -32, smallDevice: -24)).isActive = true
        proposedInterlocutorThumbsContainerView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        proposedInterlocutorThumbsContainerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        proposedInterlocutorAvatarImageView.leadingAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.leadingAnchor).isActive = true
        proposedInterlocutorAvatarImageView.topAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.topAnchor, constant: 80).isActive = true
        proposedInterlocutorAvatarImageView.bottomAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.bottomAnchor).isActive = true
        proposedInterlocutorAvatarImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        proposedInterlocutorAvatarImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        dislikeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        dislikeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        dislikeButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor).isActive = true
        dislikeButton.topAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.bottomAnchor).isActive = true
        dislikeButton.heightAnchor.constraint(equalToConstant: 140).isActive = true
        dislikeButton.widthAnchor.constraint(equalTo: likeButton.widthAnchor, multiplier: 1).isActive = true

        likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        likeButton.leadingAnchor.constraint(equalTo: dislikeButton.trailingAnchor).isActive = true
        likeButton.topAnchor.constraint(equalTo: proposedInterlocutorInfoContainerView.bottomAnchor).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 140).isActive = true
        likeButton.widthAnchor.constraint(equalTo: dislikeButton.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func addActions() {
        likeButton.tap
            .emit(onNext: { [weak self] in
                self?.like?()
            })
            .disposed(by: disposeBag)

        dislikeButton.tap
            .emit(onNext: { [weak self] in
                self?.dislike?()
            })
            .disposed(by: disposeBag)
        
        reportButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.report?()
            })
            .disposed(by: disposeBag)
    }
}
