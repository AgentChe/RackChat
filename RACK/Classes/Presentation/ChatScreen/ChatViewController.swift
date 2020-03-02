//
//  ChatViewController.swift
//  RACK
//
//  Created by Алексей Петров on 16/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import RxSwift

final class ChatViewController: UIViewController {
    private lazy var tableView: ChatTableView = {
        let view = ChatTableView()
        view.separatorStyle = .none
        view.allowsSelection = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var chatInputView: ChatInputView = {
        let view = ChatInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var chatInputViewBottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    private var chat: AKChat!
    private var viewModel: ChatViewModel!
    
    init(chat: AKChat) {
        self.chat = chat
        self.viewModel = ChatViewModel(chat: chat)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = .white
        
        addSubviews()
        
        viewModel.sender()
            .subscribe()
            .disposed(by: disposeBag)
        
        view.rx.keyboardHeight
            .subscribe(onNext: { [weak self] keyboardHeight in
                var inset = keyboardHeight
                
                if inset > 0, UIDevice.current.hasBottomNotch {
                    inset -= 35
                }
                self?.chatInputViewBottomConstraint.constant = inset
                
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        tableView.reachedTop
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
        
        tableView.viewedMessaged
            .bind(to: viewModel.viewedMessage)
            .disposed(by: disposeBag)
        
        viewModel.newMessages
            .drive(onNext: { [weak self] newMessages in
                self?.tableView.add(messages: newMessages)
            })
            .disposed(by: disposeBag)
            
        let hideKeyboardGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(hideKeyboardGesture)
        
        hideKeyboardGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.disconnect()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(chatInputView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor).isActive = true
        
        chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chatInputViewBottomConstraint = chatInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        chatInputViewBottomConstraint.isActive = true
        
        addInterlocutorImage()
    }
    
    private func addInterlocutorImage() {
        let menuImageView = UIImageView()
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        menuImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        if let interlocutorAvatarUrl = chat.interlocutorAvatarUrl {
            menuImageView.kf.setImage(with: interlocutorAvatarUrl)
        }
        
        let barItem = UIBarButtonItem(customView: menuImageView)
        navigationItem.setRightBarButton(barItem, animated: true)
        
        let tapGesture = UITapGestureRecognizer()
        menuImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let unmatchAction = UIAlertAction(title: "unmatch".localized, style: .default) { _ in
                    let vc = UnmatchViewController(nibName: "UnmatchViewController", bundle: .main)
                    self.present(vc, animated: true)
                }
                
                let reportAction = UIAlertAction(title: "report".localized, style: .default) { _ in
                    let vc = ReportViewController(chat: self.chat)
                    self.present(vc, animated: true)
                }
                
                let doneAction = UIAlertAction(title: "done".localized, style: .cancel)
                
                actionSheet.addAction(unmatchAction)
                actionSheet.addAction(reportAction)
                actionSheet.addAction(doneAction)
                
                self.present(actionSheet, animated: true)
                
            })
            .disposed(by: disposeBag)
    }
}
