//
//  Models.swift
//  DatingKit
//
//  Created by Алексей Петров on 09.10.2019.
//

import Foundation


public struct ChatItem {
    public var chatID: Int
    public var partnerName: String
    public var partnerAvatarString: String
    public var lastMessageBody: String
    public var lastMessageType: MessageType
    public var unreadCount: Int
    public var time: String
    public var position: Int = 0
    
    public init(chatID: Int, partnerName: String, avatarURL: String) {
        self.chatID = chatID
        self.partnerName = partnerName
        self.partnerAvatarString = avatarURL
        self.lastMessageBody = ""
        self.lastMessageType = .none
        self.unreadCount = 0
        self.time = ""
        self.position = 0
    }
    
    public init(metch: Match) {
        chatID = (metch.data?.match)!
        partnerName = (metch.data?.matchedUserName)!
        partnerAvatarString = (metch.data?.matchedAvatarString)!
        lastMessageBody = ""
        lastMessageType = .none
        unreadCount = 0
        time = ""
        position = 0
    }
    
    init(item: ChatListItem) {
        chatID = item.id
        partnerName = item.partnerName
        partnerAvatarString = item.partnerAvatarString
        lastMessageBody = item.lastMessageBody
        lastMessageType = MessageType(rawValue: item.lastMessageType.value!)!
        unreadCount = item.unreadCount.value!
        time = item.time
    }
    
    init(message item: MessageListItem) {
        chatID = item.chatId
        partnerName = item.partnerName
        partnerAvatarString = item.partnerAvatarStr
        lastMessageBody = item.lastMessageBody ?? ""
        lastMessageType = item.messageType!
        unreadCount = item.unreadCount
        
        if item.time != nil {
            time = item.time!
        } else {
            time = ""
        }
    }
}

public class ChatListResult: Result {
    
    public var status: ResultStatus
    public var itemsList: [ChatItem]
    
    init(itemsList: [ChatItem], status: ResultStatus) {
        self.itemsList = itemsList
        self.status = status
    }
}

public class ChatsResult: Result {
    
    public var status: ResultStatus
    public var modifid: ChatListModifidState
    
    
    init(modifid: ChatListModifidState, status: ResultStatus) {
        self.modifid = modifid
        self.status = status
        
    }
    
}

public class ChatListModifidResult: Result {
    
    public var status: ResultStatus
    public var modifidState: ChatListModifidState
    public var itemsList: [ChatItem]
    public var updated: [IndexPath]
    public var added: [IndexPath]
    public var deleted: [IndexPath]
    
    init(modifit: ChatListModifidState,
         operationState: ResultStatus,
         itemsList: [ChatItem],
         updated: [IndexPath],
         added: [IndexPath],
         deleted: [IndexPath]) {
        
        self.modifidState = modifit
        self.status = operationState
        self.itemsList = itemsList
        self.added = added
        self.updated = updated
        self.deleted = deleted
    }
    
}

public enum ChatListModifidState: Int {
    case connected
    case updated
    case added
    case removed
    case none
    case disconnected
}

public struct ChatListPosition {
    public var oldPosition: Int = 0
    public var newPosition: Int = 0
}


public struct Message: Equatable {
    
    public var messageID: Int
    public var matchID: Int
    public var senderID: Int
    public var type: MessageType
    public var body: String
    public var sendet: Bool
    public var caheID:  String
    public var sendetImage: UIImage?
    public var base64Image: String = ""
    
    init(unsendetMessage: UnsendetMessageRealm) {
        messageID = 0
        matchID = unsendetMessage.matchID
        senderID = unsendetMessage.senderID.value!
        type = MessageType(rawValue: unsendetMessage.type.value!)!
        body = unsendetMessage.body
        sendet = unsendetMessage.sendet
        caheID = unsendetMessage.cacheID
    }
    
    init(realm: MessageRealm) {
        messageID = realm.id
        senderID = realm.senderID.value!
        type = MessageType(rawValue: realm.type.value!)!
        sendetImage = UIImage()
        body = realm.body
        matchID = realm.matchID
        sendet = realm.sendet
        caheID = realm.cacheID
    }
    
    public init(message: MessageItem, matchID: Int) {
        messageID = message.messageID
        senderID = message.senderID
        type = message.type
        body = message.body
        self.matchID = matchID
        sendet = true
        caheID = UUID().uuidString
    }
    
    public init(text: String, sender: Int, matchID: Int) {
        messageID = 0
        senderID = sender
        type = .text
        body = text
        self.matchID = matchID
        caheID = UUID().uuidString
        sendet = false
    }
    
    public init(image: UIImage, forSender: Int,  matchID: Int) {
        messageID = 0
        self.sendetImage = image
        senderID = forSender
        type = .image
        body = ""
        self.matchID = matchID
        caheID = UUID().uuidString
        sendet = false
    }
    
    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.messageID == rhs.messageID && lhs.matchID == rhs.matchID && lhs.body == rhs.body
    }
}

open class SendetResult: Result {
    
    public var status: ResultStatus
    public var message: Message
    
    init(message: Message, status: ResultStatus) {
        self.message = message
        self.status = status
    }
    
}

open class MessagesResult: Result {
    
    public var status: ResultStatus
    public var messages: [Message]
    
    init(messages: [Message], operationStatus: ResultStatus) {
        self.messages = messages
        self.status = operationStatus
    }
    
    
}
