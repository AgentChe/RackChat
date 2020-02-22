//
//  CurrentChat.swift
//  DatingKit
//
//  Created by Алексей Петров on 04/10/2019.
//

import Foundation
import PromiseKit


class CurrentChatWorker: Worker {
    
    private var manager: Manager
    private var requestTool: RequestTool
    private var errorTool: ErrorTool
    private var cacheTool: CacheTool
    private var handler: (_ result: MessagesResult) -> Void = {_ in }
    private var connectionTimer: Timer?
    private var currentConnectionTask: TrakerTask?
    private var currentConnectionMessages:[Message] = [Message]()
    private var sendetMessages: [Message] = [Message]()
    private var currentChat: Int = 0
    private var waitingOfAnswer: Bool = false
    
    var currentTaskStatus: TaskStatus {
        return .waiting
    }
    
    init(manager: Manager, requestTool: RequestTool, errorTool: ErrorTool, cacheTool: CacheTool) {
        self.manager = manager
        self.requestTool = requestTool
        self.cacheTool = cacheTool
        self.errorTool = errorTool
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    func canProcess() -> Bool {
        return true
    }
    
    func perfom(task: TrakerTask) {
        
        let chatTaskType: CurrentChatTaskTypes = CurrentChatTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        
        switch chatTaskType {
     
        case .connectToCurrentChat:
            connect(task: task)
            break
        case .getMessagesFromID:
            getMessages(task: task)
            break
        case .dissconectForCurrentChat:
            disconnect(task: task)
            break
        case .sendMessage:
            sendMessage(task: task)
            break
        case .getUnsendetMessages:
            getUnsendetMessages(task: task)
            break
        case .deleteUnsendetMessage:
            deleteUnsendetMessage(task: task)
            break
        }
    }
    
    private func disconnect(task: TrakerTask) {
        connectionTimer?.invalidate()
        if currentConnectionTask != nil {
            manager.traker.removeAutorepeadedTask(trakerTask: currentConnectionTask!)
        }
        handler = {_ in }
        currentConnectionMessages = [Message]()
        currentChat = 0
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    
    private func deleteUnsendetMessage(task: TrakerTask){
        guard let userTask: CurrentChatDeleteUnsendet = task.userTask as? CurrentChatDeleteUnsendet else {
            errorTool.postError(task: task, result: SystemResult(status: .undifferentError), messsage: "Wrong task", status: .failed)
            return
        }
        
        cacheTool.delete(unsendetMessage: userTask.message)
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    
    private func getUnsendetMessages(task: TrakerTask) {
        guard let chatId: Int = task.userTask.parametrs["chat_id"] as? Int else {
            errorTool.postError(message: "Chat ID is missing!!!", process: "Current Chat Get Unsendet")
            return
        }
        
        let unsendetMessages: [Message] =  cacheTool.getUnsendet(id: chatId)        
        close(task: task, with: MessagesResult(messages: unsendetMessages, operationStatus: .succses), task: .done)
    }
    
    private func getMessages(task: TrakerTask) {
        guard let chatId: Int = task.userTask.parametrs["chat_id"] as? Int else {
            errorTool.postError(message: "Chat ID is missing!!!", process: "Current Chat get messages")
            return
        }
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: MessagesResult(messages: [Message](),
                                                       operationStatus: .noInternetConnection),
                                messsage: "No Internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: Messages = try JSONDecoder().decode(Messages.self, from: data)
                                    return response
                                } catch let error {
                                    self.errorTool.postError(task: task,
                                                             result: MessagesResult(messages: [Message](),
                                                                                    operationStatus: .undifferentError),
                                                             messsage: error.localizedDescription,
                                                             status: .failed)
                                    return nil
                                }
        }) { [weak self] (responce) in
            if responce == nil {
                self!.close(task: task, with: MessagesResult(messages: [Message](), operationStatus: .undifferentError), task: .failed)
                return
            }
            
            if responce?.httpCode == 200 {
                let messagesBundle: Messages = responce as! Messages
                if messagesBundle.data?.count != 0 {
                    var messages: [Message] = [Message]()
                    messagesBundle.data?.forEach({ (messageItem) in
                        let message: Message = Message(message: messageItem, matchID: chatId)
                        self?.cacheTool.add(message: message)
                        if self!.currentConnectionMessages.contains(where: { (messageItem) -> Bool in
                            return message.messageID == messageItem.messageID
                        }) == false {
                             messages.append(message)
                        }
                    })
                    self!.currentConnectionMessages.append(contentsOf: messages)
                    self!.close(task: task, with: MessagesResult(messages: messages, operationStatus: .succses), task: .done)
                }
            } else if responce?.httpCode == 500 {
                self!.close(task: task, with: MessagesResult(messages: [Message](), operationStatus: .badGateway), task: .failed)
            } else if responce?.needPayment == true {
                self!.close(task: task, with: MessagesResult(messages: [Message](), operationStatus: .needPayment), task: .failed)
            }
        }
    }
    
    private func sendMessage(task: TrakerTask) {
        
        guard let userTask: SendMessageTask = task.userTask as? SendMessageTask else {
            errorTool.postError(task: task, result: SystemResult(status: .undifferentError), messsage: "Wrong task", status: .failed)
            return
        }
        
        self.cacheTool.add(unsendetMessage: userTask.message)
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SendetResult(message: userTask.message, status: .noInternetConnection),
                                messsage: "No Internet Connection",
                                status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: SendStruct = try JSONDecoder().decode(SendStruct.self, from: data)
                                    return response
                                } catch let error {
                                    debugPrint(error.localizedDescription)
                                    return nil
                                }
                               
        }) { (result) in
            if result == nil {
                self.close(task: task, with: SendetResult(message: userTask.message, status: .undifferentError), task: .failed)
            }
            
            if result?.httpCode == 200 {
                let sendet: SendStruct = result as! SendStruct
                var message: Message = Message(message: (sendet.data?.first)!, matchID: self.currentChat)
                
                message.base64Image = userTask.message.base64Image
                if message.type == .image {
                    message.sendetImage = userTask.message.sendetImage
                }
                message.caheID = userTask.message.caheID
                message.sendet = true
                
                self.cacheTool.updateSendet(message: message)
                self.currentConnectionMessages.append(message)
                self.close(task: task, with: SendetResult(message: message, status: .succses), task: .done)
            } else if result?.needPayment == true {
                self.close(task: task, with: SendetResult(message: userTask.message, status: .needPayment), task: .failed)
            } else if result?.httpCode == 500 {
                self.close(task: task, with: SendetResult(message: userTask.message, status: .badGateway), task: .failed)
            } else if result?.httpCode == 400 {
                self.close(task: task, with: SendetResult(message: userTask.message, status: .undifferentError), task: .failed)
            }
        }
    }
    
    private func read(messages: [Message]) {
        
        var IDs: [Int] = [Int]()
        var returnedMessages: [Message] = [Message]()
        messages.forEach { (message) in
            IDs.append(message.messageID)
            if self.cacheTool.messageExist(id: message.messageID) == false {
                returnedMessages.append(message)
            }
        }
        
        self.currentConnectionMessages = returnedMessages + currentConnectionMessages
        
        self.currentConnectionMessages.forEach { (message) in
            self.cacheTool.add(message: message)
        }
        
        
        if NetworkState.isConnected() == false {
            handler(MessagesResult(messages: returnedMessages, operationStatus: .noInternetConnection))
            errorTool.postError(message: "No interned Connection", process: "Read")
            return
        }
        
        requestTool.request(route: "/chats/mark",
                            parameters: ["message_ids" : IDs],
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
                                    return response
                                } catch let error {
                                    debugPrint(error.localizedDescription)
                                    return nil
                                }
        }) { [weak self] (result) in
            if result == nil {
                self?.handler(MessagesResult(messages: returnedMessages, operationStatus: .undifferentError))
            }
            if result?.httpCode == 200 {
                self?.handler(MessagesResult(messages: returnedMessages, operationStatus: .succses))
            } else if result?.httpCode == 500 {
                self?.handler(MessagesResult(messages: returnedMessages, operationStatus: .badGateway))
            } else if result?.httpCode == 400 {
                self?.handler(MessagesResult(messages: [Message](), operationStatus: .forbitten))
            }
                      
        }

    }
    
    private func getCachedChat(chatId: Int) -> [Message] {
        return cacheTool.getChatMessages(id: chatId)
    }
    
    private func statrConnection(task: TrakerTask) {
        
        manager.traker.setAutoReopenedTask(trakerTask: task)
        handler = task.handler
        guard let chatId: Int = task.userTask.parametrs["chat_id"] as? Int else {
            errorTool.postError(message: "Chat ID is missing!!!", process: "Current Chat Connect")
            return
        }
        
        if connectionTimer != nil {
            connectionTimer?.invalidate()
        }
        
        connectionTimer = Timer.scheduledTimer(withTimeInterval: Settings.chatUpdatingTimer, repeats: true, block: { (timer) in
            
//            if self.waitingOfAnswer {
//                return
//            }
            
            self.waitingOfAnswer = true
            
            if NetworkState.isConnected() == false {
                timer.invalidate()
                self.handler(MessagesResult(messages: [Message](), operationStatus: .noInternetConnection))
                return
            }
            
            
            
            self.requestTool.request(route: task.userTask.route,
                                     parameters: task.userTask.parametrs,
                                     useToken: true,
                                     parcer: { (data) -> Response? in
                                        do {
                                            let response: Messages = try JSONDecoder().decode(Messages.self, from: data)
                                            return response
                                        } catch let error {
                                            debugPrint(error.localizedDescription)
                                            return nil
                                        }
            }) { [weak self] (responce) in
                
                self!.waitingOfAnswer = false
                
                if responce == nil {
                    self?.handler(MessagesResult(messages: [Message](), operationStatus: .undifferentError))
                    return
                }
                
                if responce?.httpCode == 200 {
                    let messagesResponce: Messages = responce as! Messages
                    var messages: [Message] = [Message]()
                    if messagesResponce.data?.count != 0 {
                        messagesResponce.data?.forEach({ (messageItem) in
                            let message: Message = Message(message: messageItem, matchID: chatId)
                            messages.append(message)
                        })
                        if messages.count > 0 {
                            self!.read(messages: messages)
                        }
                        
                    }
                    
                } else if responce?.httpCode == 500 {
                    self?.handler(MessagesResult(messages: [Message](), operationStatus: .badGateway))
                } else if responce?.httpCode == 400 {
                    self?.handler(MessagesResult(messages: [Message](), operationStatus: .forbitten))
                }
            }
            
        })
        
    }
    
    private func connect(task: TrakerTask) {
        guard let chatId: Int = task.userTask.parametrs["chat_id"] as? Int else {
            errorTool.postError(message: "Chat ID is missing!!!", process: "Current Chat Connect")
            return
        }
        
        currentChat = chatId
        
        if NetworkState.isConnected() == false {
            let messageList: [Message] = getCachedChat(chatId: chatId)
            errorTool.postError(task: task,
                                result: MessagesResult(messages: messageList, operationStatus: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        let cachedMessages: [Message] = getCachedChat(chatId: chatId)
        
        requestTool.request(route: "/chats/get",
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: Messages = try JSONDecoder().decode(Messages.self, from: data)
                                    return response
                                } catch let error {
                                    debugPrint(error.localizedDescription)
                                    return nil
                                }
                               
        }) { [weak self] (result) in
            if self!.errorTool.validate(responce: result,
                                       task: task,
                                       result: MessagesResult(messages: cachedMessages,
                                                              operationStatus: .undifferentError)) {
                let messagesResponce: Messages = result as! Messages
                var messages: [Message] = [Message]()
                messagesResponce.data?.forEach({ (messageItem) in
                    let message: Message = Message(message: messageItem, matchID: chatId)
                    self?.cacheTool.add(message: message)
                    if self!.currentConnectionMessages.contains(where: { (messageItem) -> Bool in
                        return message.messageID == messageItem.messageID
                    }) == false {
                         messages.append(message)
                    }
                })
                self?.statrConnection(task: task)
                self!.close(task: task, with: MessagesResult(messages: messages, operationStatus: .succses), task: .done)
            }
        }
    
    }
    
}
