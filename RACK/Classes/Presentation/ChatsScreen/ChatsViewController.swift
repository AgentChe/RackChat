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
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var backroundView: UIView!
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: ChatsTableView!
    
    private let viewModel = ChatsViewModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newSearchView.isHidden = true
        backgroundViewHeight.constant = 0
        buttonHeight.constant = 0
        backroundView.layer.cornerRadius = 0
        
        tableView.didSelectChat
            .subscribe(onNext: { [weak self] chat in
                let vc = ChatViewController(chat: chat)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.newChats
            .drive(onNext: { [weak self] chats in
                let isEmpty = chats.isEmpty
                
                self?.tableView.isHidden = isEmpty
                self?.emptyMessage.isHidden = !isEmpty
                self?.backroundView.isHidden = isEmpty
                self?.newSearchView.isHidden = isEmpty
                
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
        
        viewModel
            .checkPaymentComplete
            .drive(onNext: { [weak self] needPayment in
                let vc: UIViewController
                
                switch needPayment {
                case true:
                    let storyboard = UIStoryboard(name: "Payment", bundle: .main)
                    vc = storyboard.instantiateInitialViewController()!
                case false:
                    let searchViewController = SearchViewController()
                    searchViewController.delegate = self
                    vc = searchViewController
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .coverVertical
                
                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Amplitude.instance()?.log(event: .chatListScr)
        
        backgroundViewHeight.constant = -20.0
        buttonHeight.constant = 80.0
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.backroundView.layer.cornerRadius = 20
        }
    }
    
    @IBAction func tapOnNewSearch(_ sender: UIButton) {
        Amplitude.instance()?.log(event: .chatListNewSearchTap)
        
        viewModel.checkPayment.accept(Void())
        
        backgroundViewHeight.constant = 0
        buttonHeight.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.backroundView.layer.cornerRadius = 0
        })
    }
    
    @IBAction func tapOnSearch(_ sender: Any) {
        viewModel.checkPayment.accept(Void())
    }
}

extension ChatsViewController: SearchViewControllerDelegate {
    func wasDismiss() {
       backgroundViewHeight.constant = -20.0
       buttonHeight.constant = 80.0
        
       UIView.animate(withDuration: 0.3) { [weak self] in
           self?.view.layoutIfNeeded()
           self?.backroundView.layer.cornerRadius = 20
       }
    }
    
    func newChat(chat: Chat) {
        let vc = ChatViewController(chat: chat)
        navigationController?.pushViewController(vc, animated: true)
    }
}
