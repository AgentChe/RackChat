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
    
    private var attachView: AttachView?
    
    private var chatInputViewBottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    private var detectAttachViewTappedDisposable: Disposable?
    
    private var chat: Chat!
    private var viewModel: ChatViewModel!
    
    private let imagePicker = ImagePicker()
    
    init(chat: Chat) {
        self.chat = chat
        self.viewModel = ChatViewModel(chat: chat)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubviews()
        addActions()
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
        addInterlocutorGalleryImages()
    }
    
    private func addInterlocutorImage() {
        let size = SizeUtils.value(largeDevice: 48, smallDevice: 44, verySmallDevice: 40)
        
        let menuImageView = UIImageView()
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        menuImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        menuImageView.contentMode = .scaleAspectFit
        
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
                    let vc = UnmatchViewController(chatId: self.chat.id, interlocutorAvatarUrl: self.chat.interlocutorAvatarUrl) 
                    self.present(vc, animated: true)
                }
                
                let reportAction = UIAlertAction(title: "report".localized, style: .default) { _ in
                    let vc = ReportViewController(on: .chatInterlocutor(self.chat))
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
    
    private func addInterlocutorGalleryImages() {
        guard !chat.interlocutorGalleryPhotos.isEmpty else {
            return
        }
        
        let photosCount: CGFloat = CGFloat(chat.interlocutorGalleryPhotos.count)
        
        let size: CGFloat = SizeUtils.value(largeDevice: 48, smallDevice: 44, verySmallDevice: 40)
        let indent: CGFloat = 4
        
        let titleView = UIView()
        titleView.frame.size = CGSize(width: photosCount * size + (photosCount - 1) * indent,
                                      height: size)
        
        var x: CGFloat = 0
        
        for url in chat.interlocutorGalleryPhotos {
            let imageView = UIImageView(frame: CGRect(x: x,
                                                      y: 0,
                                                      width: size,
                                                      height: size))
            
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.kf.setImage(with: url)
            
            titleView.addSubview(imageView)
            
            x += size + indent
            
            let tapGesture = UITapGestureRecognizer()
            imageView.addGestureRecognizer(tapGesture)
            
            tapGesture.rx.event
                .map { _ in url }
                .subscribe(onNext: { [weak self] url in
                    let vc = ImageViewController(url: url)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)
        }
        
        navigationItem.titleView = titleView
    }
    
    private func addActions() {
        viewModel
            .chatRemoved()
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.sender()
            .subscribe()
            .disposed(by: disposeBag)
        
        view.rx.keyboardHeight
            .subscribe(onNext: { [weak self] keyboardHeight in
                var inset = keyboardHeight
                
                if inset > 0, UIDevice.current.hasBottomNotch {
                    inset -= 35
                }
                self?.chatInputViewBottomConstraint.constant = -inset
                
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
        
        chatInputView.sendTapped
            .asObservable()
            .withLatestFrom(chatInputView.text)
            .subscribe(onNext: { [weak self] text in
                guard let message = text?.trimmingCharacters(in: .whitespaces), !message.isEmpty else {
                    return
                }
                
                self?.viewModel.sendText.accept(message)
                self?.chatInputView.set(text: "")
            })
            .disposed(by: disposeBag)
        
        chatInputView.attachTapped
            .emit(onNext: { [weak self] state in
                guard let `self` = self else {
                    return
                }
                
                switch state {
                case .attach:
                    guard self.attachView == nil else {
                        return
                    }
                    
                    let attachView = AttachView(frame: CGRect(x: 8,
                                                              y: self.chatInputView.frame.origin.y - self.chatInputView.frame.height - 10,
                                                              width: 260,
                                                              height: 60))
                    self.attachView = attachView
                    self.view.addSubview(attachView)
                    
                    self.detectAttachViewTapped()
                case .close:
                    self.attachView?.removeFromSuperview()
                    self.attachView = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func detectAttachViewTapped() {
        detectAttachViewTappedDisposable?.dispose()
        
        detectAttachViewTappedDisposable = attachView?.caseTapped
            .emit(onNext: { [weak self] tapped in
                guard let `self` = self else {
                    return
                }
                
                switch tapped {
                case .photo:
                    self.attachView?.removeFromSuperview()
                    self.attachView = nil
                    
                    self.chatInputView.set(attachState: .attach)
                    
                    self.imagePicker.present(from: self) { image in
                        self.viewModel.sendImage.accept(image)
                    }
                }
            })
    }
}
