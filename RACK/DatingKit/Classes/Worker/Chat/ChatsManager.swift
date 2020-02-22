//
//  ChatsManager.swift
//  FAWN
//
//  Created by Алексей Петров on 21/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit



class ChatWorker: Worker {
    
    private var manager: Manager
    private var requestTool: RequestTool
    private var errorTool: ErrorTool
    private var cacheTool: CacheTool
    private var route: String
    private var parameters: [String : Any] = [String : Any]()
    private var chatListConnectionTask: TrakerTask?
    private var waitingOfAnswer: Bool = false
    
    private let listParcer: (_ data: Data) -> Response? =  { (_ data: Data) in
        do {
            let response:MessageList = try JSONDecoder().decode(MessageList.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    private var listUpdatingHandler: (_ result: ChatListModifidResult) -> Void = {_ in }
    private var getListHandler: (_ result: ChatListResult) -> Void = {_ in }
    
    private var listRequestTimer: Timer?
    
    var currentTaskStatus: TaskStatus {
        return .none
    }
    
    init(manager: Manager, requestTool: RequestTool, errorTool: ErrorTool, cacheTool: CacheTool) {
        self.manager = manager
        self.requestTool = requestTool
        self.cacheTool = cacheTool
        self.errorTool = errorTool
        route = ""
    }
    
    func canProcess() -> Bool {
        return true
    }
    
    func perfom(task: TrakerTask) {
        let chatTaskType: ChatTaskTypes = ChatTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        
        switch chatTaskType {
        
        case .connectToListFetching:
            startListCheck(task: task)
            break
        case .disconectTolistFetching:
            disconect(task: task)
            break
        case .getChatList:
            getChatList(task: task)
            break
            
        }
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    private func getCahedArray() -> [ChatItem] {
        var itemsList:[ChatItem] = [ChatItem]()
        if let realmList: [ChatListItem] = self.cacheTool.getChatList() {
            var listChat: [ChatItem] = [ChatItem]()
            realmList.forEach { (realmItem) in
                let item: ChatItem = ChatItem(item: realmItem)
                listChat.append(item)
            }
            
            itemsList = listChat
            
        }
        
        return itemsList
        
    }
    
    private func disconect(task: TrakerTask) {
        listRequestTimer?.invalidate()
        if chatListConnectionTask != nil {
            manager.traker.removeAutorepeadedTask(trakerTask: chatListConnectionTask!)
        }
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    
    private func sendErrorResult(responce: Response, operationState: ResultStatus) {
        var itemsList:[ChatItem] = [ChatItem]()
        if let realmList: [ChatListItem] = self.cacheTool.getChatList() {
            var listChat: [ChatItem] = [ChatItem]()
            realmList.forEach { (realmItem) in
                let item: ChatItem = ChatItem(item: realmItem)
                listChat.append(item)
            }
            itemsList = listChat
            
        }
        
        errorTool.postError(message: responce.message, process: "chat list updating")
        listUpdatingHandler(ChatListModifidResult(modifit: .none,
                                                  operationState: operationState,
                                                  itemsList: itemsList,
                                                  updated: [IndexPath](),
                                                  added: [IndexPath](),
                                                  deleted: [IndexPath]()))
        
    }
    
    private func startListCheck() {
        if route == "" {
            self.errorTool.postError(message:"CORE PANIC! cant start checking list of chats! please check your code!!",
                                     process: "chat list updating")
            return
        }
        self.listRequestTimer = Timer.scheduledTimer(withTimeInterval: Settings.chatsUpdatingTime, repeats: true, block: { [weak self] (timer) in
           
            if NetworkState.isConnected() == false {
                self!.listRequestTimer!.invalidate()
                self?.listUpdatingHandler(ChatListModifidResult( modifit: .none,
                                                                operationState: .noInternetConnection,
                                                                itemsList: (self?.getCahedArray())!,
                                                                updated: [IndexPath](),
                                                                added: [IndexPath](),
                                                                deleted: [IndexPath]()))
                return
            }
            
             debugPrint("lISTEN......")
            self?.requestTool.request(route: self!.route,
                                      parameters: self!.parameters,
                                      useToken: true,
                                      parcer: self!.listParcer,
                                      completion:
                { [weak self] (responce) in
                    
                    self!.waitingOfAnswer = false
                    
                    if responce == nil {
                        self?.listUpdatingHandler(ChatListModifidResult( modifit: .none,
                                                                         operationState: .undifferentError,
                                                                         itemsList: (self?.getCahedArray())!,
                                                                         updated: [IndexPath](),
                                                                         added: [IndexPath](),
                                                                         deleted: [IndexPath]()))
                        return
                    }
                    
                    if responce?.httpCode == 200 {
                        let list: MessageList = responce as! MessageList
                        
                            var listChat: [ChatItem] = [ChatItem]()
                        if list.data != nil {
                            list.data!.forEach { (item) in
                                let item: ChatItem = ChatItem(message: item)
                                listChat.append(item)
                            }
                        }
                            
                        
                        self?.cacheTool.chatUpdate(chats: listChat)
                        
                        self!.listUpdatingHandler(ChatListModifidResult(modifit: .none,
                                                                                      operationState: .succses,
                                                                                      itemsList: listChat,
                                                                                      updated: [IndexPath](),
                                                                                      added: [IndexPath](),
                                                                                      deleted: [IndexPath]()))

                    } else if responce?.httpCode == 500 {
                        timer.invalidate()
                        self!.sendErrorResult(responce: responce!, operationState: .badGateway)
                    } else if responce?.httpCode == 403 {
                        timer.invalidate()
                        self!.sendErrorResult(responce: responce!, operationState: .forbitten)
                    } else {
                        timer.invalidate()
                        self!.sendErrorResult(responce: responce!, operationState: .undifferentError)
                    }
                    
            })
        })
    }
    
    private func startListCheck(task: TrakerTask) {
        self.route = task.userTask.route
        self.parameters = task.userTask.parametrs
        manager.traker.setAutoReopenedTask(trakerTask: task)
        self.chatListConnectionTask = task
        listUpdatingHandler = task.handler
        var currentTask: TrakerTask = task
        currentTask.status = .done
        manager.traker.close(trakerTask: currentTask)
        startListCheck()
    }
    
    private func getChatList(task: TrakerTask) {
        
        
        if NetworkState.isConnected() == false {
            if let chatList: [ChatListItem] = cacheTool.getChatList() {
                var list: [ChatItem] = [ChatItem]()
                chatList.forEach { (itemRealm) in
                    let item: ChatItem = ChatItem(item: itemRealm)
                    list.append(item)
                }
                errorTool.postError(task: task,
                                    result: ChatListResult(itemsList: list, status: .noInternetConnection),
                                    messsage: "No internet Connection",
                                    status: .failedFromInternetConnection)
            }
            errorTool.postError(task: task,
                                result: ChatListResult(itemsList: [ChatItem](), status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        if listRequestTimer == nil {
            self.requestTool.request(route: task.userTask.route,
                                      parameters: task.userTask.parametrs,
                                      useToken: true,
                                      parcer: listParcer,
                completion: { [weak self] (responce) in
                if (self?.errorTool.validate(responce: responce, task: task))! {
                    let list: MessageList = responce as! MessageList
                    if self?.cacheTool.getChatList() == nil {
                        var chatsList: [ChatItem] = []
                        if list.data != nil {
                            for (index, item) in (list.data?.enumerated())! {
                                var chatItem: ChatItem = ChatItem(message: item)
                                chatItem.position = index
                                chatsList.append(chatItem)
                            }
                        
                        }
                       
                        self?.cacheTool.createChatListDataSource(items: chatsList)
                        self!.getListHandler = task.handler
                        self?.close(task: task, with: ChatListResult(itemsList: chatsList, status: .succses), task: .done)
                        
                    }
                }
            })
        }
        
    }
}
