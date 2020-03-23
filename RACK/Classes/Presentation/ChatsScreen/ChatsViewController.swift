//
//  ChatsViewController.swift
//  RACK
//
//  Created by Алексей Петров on 02/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import RxSwift

final class ChatsViewController: UIViewController {
    @IBOutlet weak var emptyMessage: UIView!
    @IBOutlet weak var newSearchView: UIView!
    @IBOutlet weak var tableView: ChatsTableView!
    @IBOutlet weak var contentView: UIView!
    
    private let viewModel = ChatsViewModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Amplitude.instance()?.log(event: .chatListScr)
        
        tableView.selectChat
            .emit(onNext: { [weak self] chat in
                let vc = ChatViewController(chat: chat)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView
            .changeItemsCount
            .emit(onNext: { [weak self] itemsCount in
                let isEmpty = itemsCount == 0
                
                self?.tableView.isHidden = isEmpty
                self?.emptyMessage.isHidden = !isEmpty
                self?.contentView.isHidden = isEmpty
                self?.newSearchView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
        
        viewModel.chats
            .drive(onNext: { [weak self] chats in
                self?.tableView.add(chats: chats)
            })
            .disposed(by: disposeBag)
        
        viewModel.chatEvent()
            .drive(onNext: { [weak self] event in
                switch event {
                case .changedChat(let chat):
                    self?.tableView.replace(chat: chat)
                case .removedChat(let chat):
                    self?.tableView.remove(chat: chat)
                case .createdChat(let chat):
                    self?.tableView.insert(chat: chat)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.connect()
    }
    
    @IBAction func tapOnNewSearch(_ sender: UIButton) {
        Amplitude.instance()?.log(event: .chatListNewSearchTap)
        
        openSearchScreen()
    }
    
    @IBAction func tapOnSearch(_ sender: Any) {
        openSearchScreen()
    }
    
    private func openSearchScreen() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
