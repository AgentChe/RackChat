//
//  ReportViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ReportViewControllerDelegate: class {
    func reportWasCreated(reportOn: ReportViewController.ReportOn)
}

class ReportViewController: UIViewController {
    enum ReportOn {
        case chatInterlocutor(Chat)
        case proposedInterlocutor(ProposedInterlocutor)
    }
    
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
    
    weak var delegate: ReportViewControllerDelegate?
    
    private var reportOn: ReportOn!
    
    private let viewModel = ReportViewModel()
    
    private let disposeBag = DisposeBag()
    
    init(on: ReportOn) {
        self.reportOn = on
        
        super.init(nibName: "ReportViewController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        switch reportOn! {
        case .chatInterlocutor(let chat):
            headerLabel.text = String(format: "report_header".localized, chat.interlocutorName)
        case .proposedInterlocutor(let proposedInterlocutor):
            headerLabel.text = String(format: "report_header".localized, proposedInterlocutor.interlocutorFullName)
        }
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
            .flatMapLatest { [weak self] report -> Driver<Void> in
                guard let viewModel = self?.viewModel, let reportOn = self?.reportOn else {
                    return Driver<Void>.empty()
                }
                
                switch reportOn {
                case .chatInterlocutor(let chat):
                    return viewModel.createOnChatInterlocutor(report: report, chatId: chat.id, proposedInterlocutorId: chat.interlocutorId)
                case .proposedInterlocutor(let proposedInterlocutor):
                    return viewModel.createOnProposedInterlocutor(report: report, proposedInterlocutorId: proposedInterlocutor.id)
                }
            }
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.delegate?.reportWasCreated(reportOn: self.reportOn!)
                self.dismiss(animated: true)
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
