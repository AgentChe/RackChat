//
//  DKChatPresenter.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class DKChatPresenter: NSObject, ChatPresenterProtocol {
    public var tableDataSource: UITableViewDataSource {
        return self
    }
    
    public var messagesCount: Int {
        return messages.count
    }
    
    public weak var view: ChatViewProtocol?
    
    public var user: UserShow!
    
    private var currentChat: ChatItem!
    
    private var messages: [Message] = [Message]()
    private var sendingMessages: [UIMessage] = [UIMessage]()
    private var menuOnScreen: Bool = false
    
    init(view: ChatViewProtocol) {
        super.init()
        
        self.view = view
    }
    
    public func configure(chat: ChatItem) {
        currentChat = chat
        
        view?.textInputView.optionalButton.addTarget(self, action: #selector(tapOnMenu), for: .touchUpInside)
        view?.textInputView.delegate = self
        
        DatingKit.user.show { (userShow, status) in
            guard self.view != nil else { return }
            if status == .noInternetConnection {
                return
            }
            
            if status == .succses {
                guard (userShow != nil) else { return }
                self.user = userShow
                
                self.getUnsendet()
                self.connect()
            }
        }
    }
    
    public func send(message: Message) {
        guard view != nil else {return}
        
        view?.menuView.show(false)
        menuOnScreen = false
        view?.textInputView.showOptional(false)
        
        view?.showNoView(false)
                  
        let newMessage: UIMessage = UIMessage(message: message, state: .sending)
        
        if sendingMessages.contains(newMessage) == false {
            self.sendingMessages.append(newMessage)
            view?.addMessage(at: IndexPath(row: 0, section: DKChatConstants.unsendetSectionNumber))
        }
        
        if message.type == .image {
            DatingKit.chat.sendImage(message: message) { (givenMessage, status) in
                self.resolveSending(messageUI: newMessage, message: givenMessage, status: status)
            }
        }
        
        if message.type == .text {
            DatingKit.chat.sendText(message: message) { (givenMessage, status) in
                self.resolveSending(messageUI: newMessage, message: givenMessage, status: status)
            }
        }
    }
    
    public func pagintaion(for indexPath: IndexPath) {
        guard let chat: ChatItem = currentChat else { return }
        if indexPath.row == messages.count - 1 {
            DatingKit.chat.getMessages(chatID: chat.chatID, messageID: messages[0].messageID) { (messages, status) in
                switch status {
                case .succses:
                    var oldMessages: Array = messages
                    if oldMessages.count > 0 {
                        oldMessages.reverse()
                        oldMessages += self.messages
                        self.messages = oldMessages
                        self.view?.reload()
                    }
                    break
                default:
                    break

                }
            }

        }
    }
    
    public func deleteUnsendet(message: Message) {
        DatingKit.chat.deleteUnsendet(message: message) { (status) in
            let deleteIndex: Int = self.sendingMessages.firstIndex(where: {$0.cacheID == message.caheID})!
            self.sendingMessages.remove(at: deleteIndex)
            self.view?.reload()
        }
    }
    
    public func disconnect() {
        DatingKit.chat.disconnectFromCurrentChat()
    }
    
    func hideMenu() {
        view?.menuView.show(false)
        menuOnScreen = false
    }
    
    @objc func tapOnMenu() {
        view?.menuView.show(!menuOnScreen)
        menuOnScreen = !menuOnScreen
    }
    
    private func resolveSending(messageUI: UIMessage, message: Message!, status: ResultStatus) {
        switch status {
            case .succses:
                self.messages.append(message!)
                let deleteIndex: Int = self.sendingMessages.firstIndex(where: {$0.cacheID == message.caheID})!
                self.sendingMessages.remove(at: deleteIndex)
                self.view?.reload()
            case .noInternetConnection:
                let index: Int = self.sendingMessages.firstIndex(where: {$0.cacheID == messageUI.cacheID})!
                self.sendingMessages[index].sendingState = .error
                self.sendingMessages[index].message.caheID = message.caheID
                self.view?.reload()
            default:
                let index: Int = self.sendingMessages.firstIndex(where: {$0.cacheID == messageUI.cacheID})!
                self.sendingMessages[index].sendingState = .error
                self.sendingMessages[index].message.caheID = message.caheID
                self.view?.reload()
        }
    }
    
    private func getUnsendet() {
        guard let chat: ChatItem = currentChat else { return }
        guard view != nil else { return }
        
        DatingKit.chat.getUnsendetMessages(chatID: chat.chatID) { (messages, status) in
            if self.sendingMessages.count == 0 {
                self.sendingMessages = messages.map({UIMessage(message: $0, state: .error)})
                self.view!.reload()
                
            } else {
                for msg: Message in messages {
                    if !self.sendingMessages.map({$0.message}).contains(msg) {
                        self.sendingMessages.append(UIMessage(message: msg, state: .error))
                        self.view?.addMessage(at: IndexPath(row: self.sendingMessages.count-1, section: 0))
                    }
                   
                }
            }
        }
    }
    
    private func connect() {
        guard let chat: ChatItem = currentChat else { return }
        
        DatingKit.chat.connectToCurrentChat(chatID: chat.chatID) { (messages, status) in
            guard self.view != nil else { return }
            switch status {
            case .succses:
                if messages.count == 0 && self.messages.count == 0  {
                    self.view?.showNoView(true)
                } else {
                    self.view?.showNoView(false)
                    if self.messages.count == 0 {
                        
                        self.messages = messages
                        self.messages.reverse()
                        
                        self.view?.reload()
                    
                    } else {
                        for msg: Message in messages {
                            
                            if !self.messages.contains(msg) {
                                self.messages.append(msg)
                                self.view?.addMessage(at: IndexPath(row: self.messages.count-1, section: 0))
                            }
                            
                        }
                    }
                }

                break
            case .noInternetConnection:
                if self.messages.count == 0 {
                    self.messages = messages
                    
                    self.view?.reload()
                }
                break
            default:
                break
            }

        }
    }
}

extension DKChatPresenter: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return DKChatConstants.sectionsCount
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == DKChatConstants.sendetSectionNumber {
            return messages.count
        }
        
        if section == DKChatConstants.unsendetSectionNumber {
            return sendingMessages.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userData: UserShow = self.user else {
            return UITableViewCell()
        }
        
        if indexPath.section == DKChatConstants.sendetSectionNumber {
            let message = messages[indexPath.row]
                if message.senderID == userData.id {
                    if message.type == .image {
                        let cell: DKUserImageTableViewCell = tableView.dequeueUserImageCell(for: indexPath)
                        cell.config(message: message, state: .sendet)
                        return cell
                    }
                    let cell: DKUserMessageTableViewCell = tableView.dequeueUserTextCell(for: indexPath)
                    cell.config(message: message, state: .sendet)
                    return cell
                } else {
                    if message.type == .image {
                        let cell: DKPartnerIMewssageImageTableViewCell = tableView.dequeuePartnerImageCell(for: indexPath)
                        cell.config(message: message)
                        return cell
                    }
                    let cell: DKPartnerMessageTableViewCell = tableView.dequeuePartnerTextCell(for: indexPath)
                    cell.config(message: message)
                    return cell
                }
            }
              
        if indexPath.section == DKChatConstants.unsendetSectionNumber {
            let message:UIMessage = sendingMessages[indexPath.row]
            if message.type == .image {
                let cell: DKUserImageTableViewCell = tableView.dequeueUserImageCell(for: indexPath)
                cell.config(message: message, presenter: self)
                return cell
            }
                
            let cell: DKUserMessageTableViewCell = tableView.dequeueUserTextCell(for: indexPath)
            cell.config(message: message, presenter: self)
            return cell
        }
        
        return  UITableViewCell()
        
    }
}

extension DKChatPresenter: DKChatBottomViewDelegate {
    public func chatBottomView(_ chatBottomView: DKChatBottomView, optional isHidden: Bool) {
        if isHidden {
            view?.menuView.show(false)
            menuOnScreen = false
        }
    }
}
