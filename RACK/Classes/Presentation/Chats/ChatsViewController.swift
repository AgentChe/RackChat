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


class ChatsViewController: UIViewController {

    @IBOutlet weak var emptyMessage: UIView!
    @IBOutlet weak var newSearchView: UIView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var backroundView: UIView!
    @IBOutlet weak var noInternetConnectionConstrait: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    
    
    private var isEditingCell: Bool = false
    private var showPaygate:Bool = false

    private var chats: [ChatItem] = []
    
    func noInternet(show: Bool) {
            if show {
                     noInternetConnectionConstrait.constant = 67.0
                     UIView.animate(withDuration: 0.4) {
                         self.view.layoutIfNeeded()
                         self.noInternetConnectionLabel.alpha = 1.0
                     }
                 } else {
                     noInternetConnectionConstrait.constant = 0.0
                     UIView.animate(withDuration: 0.4, animations: {
                         self.view.layoutIfNeeded()
                     }) { (fin) in
                          self.noInternetConnectionLabel.alpha = 0.0
                     }
                 }
     
        
    }
    
    @objc func handleMatch() {
        self.performSegue(withIdentifier: "search", sender: MatchScreenState.foundet)
    }
    
    @objc func handlePush() {
        
        guard let chat: ChatItem = ScreenManager.shared.pushChat else { return }
        
        if let currentChat: ChatItem = ScreenManager.shared.chatItemOnScreen {
            if currentChat.chatID == chat.chatID {
                return
            }
        }
        
        self.performSegue(withIdentifier: "chat", sender: chat)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
        self.newSearchView.isHidden = true
        tableView.register(UINib(nibName: "СhatsTableViewCell", bundle: .main), forCellReuseIdentifier: "ChatsCell")
        self.backgroundViewHeight.constant = 0
        self.buttonHeight.constant = 0
        self.backroundView.layer.cornerRadius = 0
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMatch), name: NotificationManager.kMatchNotify, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePush),
                                               name: NotificationManager.kMessageNotify,
                                               object: nil)
        if ScreenManager.shared.showChat == false {
            
            if  ScreenManager.shared.match != nil {
                self.performSegue(withIdentifier: "search", sender: MatchScreenState.foundet)
            } else {
                if ScreenManager.shared.autoChat == true {
                    self.performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
                } else {
                    self.performSegue(withIdentifier: "search", sender: MatchScreenState.serchingManuality)
                }
            }
            
        } else {
            if let chat: ChatItem = ScreenManager.shared.pushChat {
                self.performSegue(withIdentifier: "chat", sender: chat)
            }
        }
        
        DatingKit.chat.getChatList { (result, status) in
            
            self.chats = result.itemsList
            if result.itemsList.count == 0 {
                self.tableView.isHidden = true
                self.backroundView.isHidden = true
                self.swipeView.isHidden = true
                self.newSearchView.isHidden = true
                if self.emptyMessage.isHidden {
                    self.emptyMessage.alpha = 0.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.emptyMessage.alpha = 1.0
                    }, completion: { (fin) in
                        self.emptyMessage.isHidden = false
                    })
                }
            } else {
                self.tableView.isHidden = false
                self.backroundView.isHidden = false
                self.swipeView.isHidden = false
                self.newSearchView.isHidden = false
                self.chats = result.itemsList
                self.tableView.reloadData()
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 1.0
                })
            }
            
            if status == .noInternetConnection {
                self.noInternet(show: true)
                
            } else {
                self.noInternet(show: false)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatingKit.chat.disconnect()
    }
    
    @objc func showPaygateView() {
        showPaygate = true
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func apper() {
        DatingKit.chat.connect { (result, status) in
            self.chats = result.itemsList
            self.tableView.reloadData()
            self.tableView.isHidden = false
                   if result.itemsList.count == 0 {
                    self.tableView.alpha = 0.0
                       self.tableView.isHidden = true
                       self.backroundView.isHidden = true
                       self.swipeView.isHidden = true
                       self.newSearchView.isHidden = true
                       if self.emptyMessage.isHidden {
                           self.emptyMessage.alpha = 0.0
                           UIView.animate(withDuration: 0.3, animations: {
                               self.emptyMessage.alpha = 1.0
                           }, completion: { (fin) in
                               self.emptyMessage.isHidden = false
                           })
                       }
                   } else {
                        self.tableView.isHidden = false
                        self.backroundView.isHidden = false
                        self.swipeView.isHidden = false
                        self.newSearchView.isHidden = false
                        self.chats = result.itemsList
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 0.3, animations: {
                           self.tableView.alpha = 1.0
                        })
                   }
                            
                  if status == .noInternetConnection {
                       self.noInternet(show: true)
                       
                   } else {
                       self.noInternet(show: false)
                   }
               }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.apper()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        showPaygate = false
        Amplitude.instance()?.log(event: .chatListScr)
        self.backgroundViewHeight.constant = -20.0
        self.buttonHeight.constant = 80.0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
            self.backroundView.layer.cornerRadius = 20
        }
    }
    
    @IBAction func tapOnNewSearch(_ sender: UIButton) {
        
        Amplitude.instance()?.log(event: .chatListNewSearchTap)
//        DatingKit.chat.disconnect()
        performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
        self.backgroundViewHeight.constant = 0
        self.buttonHeight.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.backroundView.layer.cornerRadius = 0
        }) { (succse) in
            
        }
    }
    
    @IBAction func tapOnSearch(_ sender: Any) {
//        DatingKit.chat.disconnect()
        performSegue(withIdentifier: "search", sender: MatchScreenState.searchng)
    }
    
    
    // MARK: - Navigation

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
            DatingKit.chat.disconnect()
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
        
        if segue.identifier == "paygate" {
            let paygate: PaymentViewController = segue.destination as! PaymentViewController
            paygate.delegate = self
        }
    }

}

extension ChatsViewController: PaymentViewControllerDelegate {
    func wasPurchased() {
        showPaygate = false
    }
    
    func wasClosed() {
        
    }
}

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showPaygate {
            self.performSegue(withIdentifier: "paygate", sender: nil)
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "chat", sender: self.chats[indexPath.row])
            }
        }
    }
    
}

extension ChatsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
        cell.config(item: chats[indexPath.row])
        return cell
    }

}

extension ChatsViewController: SearchViewDelegate {
    func wasDismis(searchView: MatchViewController) {
         apper()
               self.backgroundViewHeight.constant = -20.0
               self.buttonHeight.constant = 80.0
               UIView.animate(withDuration: 0.4) {
                   self.view.layoutIfNeeded()
                   self.backroundView.layer.cornerRadius = 20
               }
    }
    
    
    func tapOnYes() {
        
    }
    
   
    
}
