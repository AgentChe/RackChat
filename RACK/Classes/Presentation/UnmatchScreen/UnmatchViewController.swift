//
//  UnmatchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

final class UnmatchViewController: UIViewController {
    @IBOutlet weak var interlocutorAvatarView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yesButton: GradientButton!
    @IBOutlet weak var noButton: UIButton!
    
    private var chatId: String!
    private var interlocutorAvatarUrl: URL?
    
    private let disposeBag = DisposeBag()
    
    func setup(chatId: String, interlocutorAvatarUrl: URL?) {
        self.chatId = chatId
        self.interlocutorAvatarUrl = interlocutorAvatarUrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if let interlocutorAvatarUrl = self.interlocutorAvatarUrl {
            interlocutorAvatarView.kf.setImage(with: interlocutorAvatarUrl)
        }
        
        descriptionLabel.text = "unmatch_message".localized
        
        yesButton.rx.tap
            .flatMapLatest { [chatId] in MatchService.unmatch(chatId: chatId!) }
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        noButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
