//
//  ProposedInterlocutor.swift
//  RACK
//
//  Created by Andrey Chernyshev on 06/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSURL

struct ProposedInterlocutor {
    let queueId: SearchingQueueId
    let interlocutorFullName: String
    let interlocutorAvatarUrl: URL?
    let gender: Gender
    let gradientColorBegin: String?
    let gradientColorEnd: String?
}

extension ProposedInterlocutor: Model {
    enum Keys: String, CodingKey {
        case queueId = "queue_id"
        case data
    }
    
    enum DataKeys: String, CodingKey {
        case name
        case avatar
        case gender
        case gradientColorBegin = "color_begin"
        case gradientColorEnd = "color_end"
    }
    
    enum AvatarKeys: String, CodingKey {
        case avatarUrl = "thumb_transparent"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        queueId = try container.decode(String.self, forKey: .queueId)
        
        let data = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        
        interlocutorFullName = try data.decode(String.self, forKey: .name)
        
        let avatar = try? data.nestedContainer(keyedBy: AvatarKeys.self, forKey: .avatar)
        
        let avatarPath = try? avatar?.decode(String.self, forKey: .avatarUrl)
        interlocutorAvatarUrl = URL(string: avatarPath ?? "")
        
        let genderValue = try data.decode(Int.self, forKey: .gender)
        guard let gender = Gender(rawValue: genderValue) else {
            throw NSError(domain: "Gender not found", code: 404, userInfo: nil)
        }
        self.gender = gender
        
        gradientColorBegin = try? data.decode(String.self, forKey: .gradientColorBegin)
        gradientColorEnd = try? data.decode(String.self, forKey: .gradientColorEnd)
    }
    
    func encode(to encoder: Encoder) throws {}
}
