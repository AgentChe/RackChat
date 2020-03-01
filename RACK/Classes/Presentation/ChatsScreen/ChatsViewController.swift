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
        
        UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
        
        newSearchView.isHidden = true
        backgroundViewHeight.constant = 0
        buttonHeight.constant = 0
        backroundView.layer.cornerRadius = 0
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
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
        
        viewModel.changedChat()
            .drive(onNext: { [weak self] chat in
                self?.tableView.replace(chat: chat)
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
