//
//  DatingChat.swift
//  DatingKit
//
//  Created by Алексей Петров on 02/10/2019.
//

import Foundation


open class Chat {
    
    private var manager: Manager
    
    init(manager: Manager) {
        self.manager = manager
    }
    
    public func connectToCurrentChat(chatID: Int, completion: @escaping (_ result:[Message], _ opereationStatus: ResultStatus) -> Void) {
        let task: ConnectCurrentChatTask = ConnectCurrentChatTask(id: chatID)
        manager.takeToWork(task: task) { (result) in
            let messagesResult: MessagesResult = result as! MessagesResult
            completion(messagesResult.messages, messagesResult.status)
        }
        
    }
    
    public func getChatList(completion: @escaping (_ result: ChatListResult, _ operationStatus: ResultStatus) -> Void) {
     
        let task: ChatListGettingTask = ChatListGettingTask()
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let responce: ChatListResult = result as! ChatListResult
                completion(responce, responce.status)
            } else if result.status == .noInternetConnection {
                let responce: ChatListResult = result as! ChatListResult
                completion(responce, responce.status)
            } else {
                completion(ChatListResult(itemsList: [ChatItem](), status: result.status), result.status)
            }
        }
        
    }
    
    public func disconnect() {
        let task: ChatListDisconnect = ChatListDisconnect()
        manager.takeToWork(task: task) { (result) in
            
        }
    }
    
    public func disconnectFromCurrentChat() {
        let task: CurrenrtChatDisconnect = CurrenrtChatDisconnect()
        manager.takeToWork(task: task) { (result) in
            
        }
    }
    
    public func getUnsendetMessages(chatID: Int, completion: @escaping (_ messages: [Message], _ operationStatus: ResultStatus) -> Void) {
        let task: CurrentChatGetUnsendet = CurrentChatGetUnsendet(id: chatID)
        manager.takeToWork(task: task) { (result) in
            let messagesResult: MessagesResult = result as! MessagesResult
            completion(messagesResult.messages, messagesResult.status)
        }
    }
    
    public func deleteUnsendet(message: Message, completion: @escaping (_ operationStatus: ResultStatus) -> Void) {
        let task: CurrentChatDeleteUnsendet = CurrentChatDeleteUnsendet(message: message)
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
   
    
    public func getMessages(chatID: Int, messageID: Int, completion: @escaping (_ messages: [Message], _ operationStatus: ResultStatus) -> Void) {
        let task: GetMessagesTask = GetMessagesTask(parameters: ["chat_id" : chatID, "message_id" : messageID])
        manager.takeToWork(task: task) { (result) in
            let responce: MessagesResult = result as! MessagesResult
            completion(responce.messages, responce.status)
        }
    }
    
    public func  sendText(message: Message, completion: @escaping (_ message: Message, _ operationStatus: ResultStatus) -> Void) {
         let task: SendMessageTask = SendMessageTask(message: message)
         manager.takeToWork(task: task) { (result) in
            if let messageResult: SendetResult = result as? SendetResult {
                completion(messageResult.message, messageResult.status)
            }
         }
    }
    
    public func sendImage(message: Message, completion: @escaping (_ message: Message?, _ operationStatus: ResultStatus) -> Void) {
         let task: SendMessageTask = SendMessageTask(message: message)
         manager.takeToWork(task: task) { (result) in
            if let messageResult: SendetResult = result as? SendetResult {
                completion(messageResult.message, messageResult.status)
            } else {
                completion(nil, result.status)
            }
              
        }
    }
    
    public func connect(completion: @escaping (_ result: ChatListModifidResult, _ operationStatus: ResultStatus) -> Void) {
        let task: ChatListConnectionTask = ChatListConnectionTask()
        
        manager.takeToWork(task: task) { (result) in
                let responce: ChatListModifidResult = result as! ChatListModifidResult
                completion(responce, responce.status)
          
        }
    }
    
}
