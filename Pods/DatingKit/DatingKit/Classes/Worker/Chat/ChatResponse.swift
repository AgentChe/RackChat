//
//  ChatResponse.swift
//  FAWN
//
//  Created by Алексей Петров on 24/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public enum MessageType: Int {
    case none = 0
    case text
    case image
}

public struct SendStruct: Response {
   public var httpCode: Double
   public var message: String
   public var needPayment: Bool
   public var data:[MessageItem]?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        data = try? contanier.decode([MessageItem].self, forKey: .data)
    }
}

public struct Messages: Response {
   public var httpCode: Double
   public var message: String
   public var needPayment: Bool
   public var data:[MessageItem]?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
//        some = try! contanier.decode(Dictionary<String, Any>.self, forKey: .data)
        data = try? contanier.decode([MessageItem].self, forKey: .data)
    }
    
}

public struct MessageItem: Decodable {
   public var messageID: Int
   public var senderID: Int
   public var type: MessageType
   public var body: String
    
    enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case userId = "user_id"
        case type
        case value
    }
    
    
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        messageID = try contanier.decode(Int.self, forKey: .messageId)
        senderID = try contanier.decode(Int.self, forKey: .userId)
        type = MessageType(rawValue: try contanier.decode(Int.self, forKey: .type)) ?? .none
        body = try contanier.decode(String.self, forKey: .value)
    }
    
}



public struct MessageList: Response {
   public var httpCode: Double
   public var message: String
   public var needPayment: Bool
   public var data:[MessageListItem]?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"

    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        data = try? contanier.decode([MessageListItem].self, forKey: .data)
    }
    
    
}

public struct MessageListItem: Decodable {
    
    public var chatId: Int
    public var partnerName: String
    public var partnerAvatarStr: String
    public var lastMessageBody: String?
    public var messageType: MessageType?
    public var unreadCount: Int
    public var time: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case partnerName = "partner_name"
        case partnerAvatar = "partner_avatar"
        case lastMessageBody = "last_message_body"
        case messageType = "last_message_type"
        case unreadMessages = "unread_message_count"
        case lastMessageTime = "last_message_timestamp"
        
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        chatId = try contanier.decode(Int.self, forKey: .id)
        partnerName = try contanier.decode(String.self, forKey: .partnerName)
        partnerAvatarStr = try contanier.decode(String.self, forKey: .partnerAvatar)
        lastMessageBody = try! contanier.decode(String.self, forKey: .lastMessageBody)
        messageType = MessageType(rawValue: try! contanier.decode(Int.self, forKey: .messageType))!
        unreadCount = try contanier.decode(Int.self, forKey: .unreadMessages)
        time = try? contanier.decode(String.self, forKey: .lastMessageTime)
    }
}
