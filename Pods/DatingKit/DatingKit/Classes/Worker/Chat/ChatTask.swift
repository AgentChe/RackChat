//
//  ChatTask.swift
//  DatingKit
//
//  Created by Алексей Петров on 01/10/2019.
//

import Foundation

public enum ChatTaskTypes: Int {
    case connectToListFetching
    case disconectTolistFetching
    case getChatList
}

public enum CurrentChatTaskTypes: Int {
    public typealias RawValue = Int
    case connectToCurrentChat
    case getMessagesFromID
    case sendMessage
    case dissconectForCurrentChat
    case getUnsendetMessages
    case deleteUnsendetMessage
}

open class CurrentChatDeleteUnsendet: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return chatTaskType.rawValue
    }
       
    private var chatTaskType: CurrentChatTaskTypes
    
    public var message: Message
    
    init(message: Message) {
        route = ""
        service = Servises.currentChat.stringValue
        autoRepeat = false
        parametrs = [String : Any]()
        needParameters = false
        chatTaskType = .deleteUnsendetMessage
        status = .none
        self.message = message
    }
    
}

open class CurrentChatGetUnsendet: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return chatTaskType.rawValue
    }
       
    private var chatTaskType: CurrentChatTaskTypes
    
    init(id: Int) {
        route = ""
        service = Servises.currentChat.stringValue
        autoRepeat = false
        parametrs = ["chat_id" : id]
        needParameters = false
        chatTaskType = .getUnsendetMessages
        status = .none
    }
}

open class CurrenrtChatDisconnect: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return chatTaskType.rawValue
    }
    
    private var chatTaskType: CurrentChatTaskTypes
    
    init() {
        route = ""
        service = Servises.currentChat.stringValue
        autoRepeat = false
        parametrs = [String : Any]()
        needParameters = false
        chatTaskType = .dissconectForCurrentChat
        status = .none
    }

}


open class SendMessageTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var message: Message
    
    public var type: Int {
         return chatTaskType.rawValue
     }
    
    private var chatTaskType: CurrentChatTaskTypes
    
    init(message: Message) {
        self.message = message
        route = "/chats/message"
        service = Servises.currentChat.stringValue
        autoRepeat = false
        needParameters = true
        chatTaskType = .sendMessage
        status = .none
        var requestParametrs: [String : Any] = ["message" : message.body,
                     "chat_id" : message.matchID,
                     "type" : message.type.rawValue]
        if message.type == .image {
            requestParametrs["message_64"] = message.base64Image
        }
        parametrs = requestParametrs
    }
    
//    init(parameters: [String : Any]) {
//        route = "/chats/message"
//        service = Servises.currentChat.stringValue
//        autoRepeat = false
//        self.parametrs = parameters
//        needParameters = true
//        chatTaskType = .sendMessage
//        status = .none
//        
//    }
    
}

open class GetMessagesTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return chatTaskType.rawValue
    }
       
    private var chatTaskType: CurrentChatTaskTypes
    
    init(parameters:[String : Any]) {
        self.parametrs = parameters
        needParameters = true
        route = "/chats/history"
        service = Servises.currentChat.stringValue
        autoRepeat = true
        chatTaskType = .getMessagesFromID
        status = .none
    }
}

open class ConnectCurrentChatTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return chatTaskType.rawValue
    }
    
    private var chatTaskType: CurrentChatTaskTypes
    
    init(id: Int) {
        route = "/chats/unread"
        service = Servises.currentChat.stringValue
        autoRepeat = false
        parametrs = ["chat_id" : id]
        needParameters = true
        chatTaskType = .connectToCurrentChat
        status = .none
    }
}

open class ChatListGettingTask: Task {
    
    public var needParameters: Bool
    
    public var route: String
    
    public var service: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus 
    
    public var type: Int {
        return chatTaskType.rawValue
    }
    
    
    private var chatTaskType: ChatTaskTypes
    
    init() {
        self.service = Servises.chats.stringValue
        self.route = "/chats/list"
        self.needParameters = false
        self.autoRepeat = true
        self.parametrs = [String : Any]()
        self.status = .none
        self.chatTaskType = .getChatList
    }
    
}

open class ChatListDisconnect: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return chatTaskType.rawValue
    }
    
    private var chatTaskType: ChatTaskTypes
    
    init() {
        self.service = Servises.chats.stringValue
        self.route = ""
        self.parametrs = [String : Any]()
        self.needParameters = false
        self.autoRepeat = false
        self.status = .none
        self.chatTaskType = .disconectTolistFetching
    }
}

open class ChatListConnectionTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return chatTaskType.rawValue
    }
    
    private var chatTaskType: ChatTaskTypes
    
    
    init() {
        self.service = Servises.chats.stringValue
        self.route = "/chats/list"
        self.needParameters = false
        self.autoRepeat = true
        self.parametrs = [String : Any]()
        self.status = .none
        self.chatTaskType = .connectToListFetching
    }
}
