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

final class ProposedInterlocutorsTableCell: UITableViewCell {
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Fonts.SPProText.regular(size: 16)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "sure_icon"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dislikeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "skip_icon"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var like: (() -> ())?
    var dislike: (() -> ())?
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(proposedInterlocutor: ProposedInterlocutor) {
        avatarImageView.kf.cancelDownloadTask()
        if let avatarUrl = proposedInterlocutor.interlocutorAvatarUrl {
            avatarImageView.kf.setImage(with: avatarUrl)
        } else {
            avatarImageView.image = nil
        }
        
        nameLabel.text = proposedInterlocutor.interlocutorFullName
    }
    
    private func configure() {
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(dislikeButton)
        
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        
        likeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        likeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 40).isActive = true
        likeButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        dislikeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dislikeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dislikeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -40).isActive = true
        dislikeButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32).isActive = true
        dislikeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
    
    private func addActions() {
        likeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.like?()
            })
            .disposed(by: disposeBag)
        
        dislikeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dislike?()
            })
            .disposed(by: disposeBag)
    }
}
