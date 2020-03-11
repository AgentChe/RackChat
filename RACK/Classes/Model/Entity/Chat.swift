//
//  Chat.swift
//  RACK
//
//  Created by Andrey Chernyshev on 20/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSURL

struct Chat {
    let id: String
    let interlocutorName: String
    let interlocutorAvatarUrl: URL?
    let unreadMessageCount: Int
    let lastMessage: Message?
}

extension Chat: Model {
    enum Keys: String, CodingKey {
        case id = "room"
        case interlocutor = "partner"
    }
    
    enum InterlocutorKeys: String, CodingKey {
        case interlocutorName = "name"
        case interlocutorAvatarUrl = "avatar"
        case unreadMessageCount = "unread"
        case lastMessage = "message"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let interlocutor = try container.nestedContainer(keyedBy: InterlocutorKeys.self, forKey: .interlocutor)
        
        interlocutorName = try interlocutor.decode(String.self, forKey: .interlocutorName)
        
        let interlocutorAvatarPath = try? interlocutor.decode(String.self, forKey: .interlocutorAvatarUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        interlocutorAvatarUrl = URL(string: interlocutorAvatarPath ?? "")
        
        unreadMessageCount = (try? interlocutor.decode(Int.self, forKey: .unreadMessageCount)) ?? 0
        lastMessage = try? interlocutor.decode(Message.self, forKey: .lastMessage)
    }
}
