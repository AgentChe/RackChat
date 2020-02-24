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
    
    @IBOutlet private weak var input: DKChatBottomView!
    @IBOutlet private weak var menuCell: DKMenuCell!
    @IBOutlet private weak var inputContainerViewBottom: NSLayoutConstraint!
    
    private var chat: AKChat!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.connect(to: chat)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.disconnect()
    }
    
    func bind(chat: AKChat) {
        self.chat = chat
    }
    
    private func addSubviews() {
        view.insertSubview(tableView, at: 0)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: input.topAnchor).isActive = true
        
        addInterlocutorImage()
    }
    
    private func addInterlocutorImage() {
        let menuImageView = UIImageView()
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        menuImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        if let interlocutorAvatarPath = chat.interlocutorAvatarPath,
            let interlocutorAvatarUrl = URL.combain(domain: GlobalDefinitions.ChatService.restDomain, path: interlocutorAvatarPath){
            menuImageView.kf.setImage(with: interlocutorAvatarUrl)
        }
        
        let barItem = UIBarButtonItem(customView: menuImageView)
        navigationItem.setRightBarButton(barItem, animated: true)
    }
}
