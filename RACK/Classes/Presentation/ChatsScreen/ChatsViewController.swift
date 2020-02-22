//
//  ChatsViewController.swift
//  RACK
//
//  Created by Алексей Петров on 02/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import NotificationBannerSwift
import Amplitude_iOS
import RxSwift

final class ChatsViewController: UIViewController {
    @IBOutlet weak var emptyMessage: UIView!
    @IBOutlet weak var newSearchView: UIView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var backroundView: UIView!
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ChatsViewModel()

    private var chats: [AKChat] = []
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
        
        newSearchView.isHidden = true
        tableView.register(UINib(nibName: "СhatsTableViewCell", bundle: .main), forCellReuseIdentifier: "ChatsCell")
        backgroundViewHeight.constant = 0
        buttonHeight.constant = 0
        backroundView.layer.cornerRadius = 0
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMatch), name: NotificationManager.kMatchNotify, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePush),
                                               name: NotificationManager.kMessageNotify,
                                               object: nil)
        
        if ScreenManager.shared.showChat == false {
            if  ScreenManager.shared.match != nil {
                performSegue(withIdentifier: "search", sender: MatchScreenState.foundet)
            } else {
                if ScreenManager.shared.autoChat == true {
                    performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
                } else {
                    performSegue(withIdentifier: "search", sender: MatchScreenState.serchingManuality)
                }
            }
            
        } else {
            if let chat: ChatItem = ScreenManager.shared.pushChat {
                performSegue(withIdentifier: "chat", sender: chat)
            }
        }
        
        viewModel.chats
            .drive(onNext: { [weak self] chats in
                self?.chats = chats
                
                let isEmpty = chats.isEmpty
                
                self?.tableView.isHidden = isEmpty
                self?.emptyMessage.isHidden = !isEmpty
                self?.backroundView.isHidden = isEmpty
                self?.tableView.isHidden = isEmpty
                self?.newSearchView.isHidden = isEmpty
                
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
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
        
        performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
        
        backgroundViewHeight.constant = 0
        buttonHeight.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.backroundView.layer.cornerRadius = 0
        })
    }
    
    @IBAction func tapOnSearch(_ sender: Any) {
        performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            guard let chat: ChatItem = sender as? ChatItem else {
                return
            }
            let chatVC: ChatViewController = segue.destination as! ChatViewController
            chatVC.config(with: chat)
        }
        
        if segue.identifier == "search" {
            let searchView: MatchViewController = segue.destination as! MatchViewController
            searchView.delegate = self
            if let startFromNewSearchButton: MatchScreenState = sender as? MatchScreenState {
                if startFromNewSearchButton == .foundet {
                    if let match: DKMatch = ScreenManager.shared.match {
                        searchView.config(state: startFromNewSearchButton, match: match)
                    } else {
                        searchView.config(state: .searchng)
                    }
                    
                } else {
                    searchView.config(state: startFromNewSearchButton)
                }
            }
        }
    }
    
    @objc private func handleMatch() {
        performSegue(withIdentifier: "search", sender: MatchScreenState.foundet)
    }
    
    @objc private func handlePush() {
        guard let chat = ScreenManager.shared.pushChat else {
            return
        }
        
        if let currentChat: ChatItem = ScreenManager.shared.chatItemOnScreen {
            if currentChat.chatID == chat.chatID {
                return
            }
        }
        
        performSegue(withIdentifier: "chat", sender: chat)
    }
}

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "chat", sender: self.chats[indexPath.row])
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
        cell.bind(chat: chats[indexPath.row])
        return cell
    }

}

extension ChatsViewController: SearchViewDelegate {
    func wasDismis(searchView: MatchViewController) {
               self.backgroundViewHeight.constant = -20.0
               self.buttonHeight.constant = 80.0
               UIView.animate(withDuration: 0.4) {
                   self.view.layoutIfNeeded()
                   self.backroundView.layer.cornerRadius = 20
               }
    }
    
    func tapOnYes() {}
}
