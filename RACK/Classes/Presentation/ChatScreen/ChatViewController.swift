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
    
    private lazy var preloader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBOutlet private weak var input: DKChatBottomView!
    @IBOutlet private weak var menuCell: DKMenuCell!
    @IBOutlet private weak var inputContainerViewBottom: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    private var chat: AKChat!
    private var viewModel: ChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
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
                self?.inputContainerViewBottom.constant = inset
                
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        tableView.rx.reachedTop
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
        
        viewModel.newMessages
            .drive(onNext: { [weak self] newMessages in
                self?.tableView.add(messages: newMessages)
            })
            .disposed(by: disposeBag)
        
        input.sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let text = self?.input.text.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                    return
                }
                
                self?.viewModel.sendText.accept(text)
                
                self?.input.text = ""
            })
            .disposed(by: disposeBag)
        
        viewModel.paginatedLoader
            .loading
            .drive(preloader.rx.isAnimating)
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
    
    func bind(chat: AKChat) {
        self.chat = chat
        
        viewModel = ChatViewModel(chat: chat)
    }
    
    private func addSubviews() {
        view.insertSubview(tableView, at: 0)
        view.addSubview(preloader)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: input.topAnchor).isActive = true
        
        preloader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        preloader.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 22).isActive = true
        
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
    }
}
