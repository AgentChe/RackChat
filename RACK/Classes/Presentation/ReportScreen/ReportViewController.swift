//
//  ReportViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import RxSwift

class ReportViewController: UIViewController {
    enum ReportType: Int {
        case inappropriateMessages = 1
        case inappropriatePhotos = 2
        case spam = 3
        case other = 4
    }
    
    struct Report {
        let type: ReportType
        let message: String?
        
        init(type: ReportType, message: String? = nil) {
            self.type = type
            self.message = message
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var otherReasonTextView: UITextView!
    @IBOutlet weak var otherReasonView: UIView!
    @IBOutlet weak var processingView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var inappropriateMessageButton: UIButton!
    @IBOutlet weak var inappropriatePhotos: UIButton!
    @IBOutlet weak var feelLikeSpamButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var otherCancelButton: UIButton!
    @IBOutlet weak var otherSendButton: UIButton!
    
    private var chat: AKChat!
    
    private let viewModel = ReportViewModel()
    
    private let disposeBag = DisposeBag()
    
    init(chat: AKChat) {
        self.chat = chat
        
        super.init(nibName: "ReportViewController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        bind()
        
        headerLabel.text = String(format: "report_header".localized, chat.interlocutorName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        DatingKit.user.show { (user, status) in
//            guard user != nil else {return}
//
//            let str: String = user?.lookingFor == .guys ? "him." : "her."
//
//            self.subtitleLabel.text = "It's anonymous, we won't tell " + str
//        }
    }
    
    private func bind() {
        viewModel.loading
            .drive(onNext: { [weak self] loading in
                self?.menuView.isHidden = loading
                self?.processingView.isHidden = !loading
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                inappropriateMessageButton.rx.tap.map { Report(type: .inappropriateMessages) },
                inappropriatePhotos.rx.tap.map { Report(type: .inappropriatePhotos) },
                feelLikeSpamButton.rx.tap.map { Report(type: .spam) },
                otherSendButton.rx.tap
                    .do(onNext: { [otherReasonView, otherReasonTextView] in
                        otherReasonView?.isHidden = true
                        otherReasonTextView?.resignFirstResponder()
                    })
                    .map { [otherReasonTextView] in Report(type: .other, message: otherReasonTextView?.text) }
            )
            .flatMapLatest { [viewModel, chat] report in
                viewModel.create(report: report, chatId: chat!.id)
            }
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        otherButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.menuView.isHidden = true
                self?.otherReasonView.isHidden = false
                self?.otherReasonTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        otherCancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.otherReasonView.isHidden = true
                self?.otherReasonTextView.resignFirstResponder()
                self?.menuView.isHidden = false
            })
            .disposed(by: disposeBag)
    }
}
