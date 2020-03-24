//
//  ProposedInterlocutor.swift
//  RACK
//
//  Created by Andrey Chernyshev on 06/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSURL

struct ProposedInterlocutor {
    let id: Int
    let interlocutorFullName: String
    let interlocutorAvatarUrl: URL?
    let gender: Gender
    let age: Int?
    let startColor: String?
    let endColor: String?
}

extension ProposedInterlocutor: Model {
    private enum Keys: String, CodingKey {
        case id
        case name
        case avatarUrl = "avatar_transparent"
        case gender
        case age
        case startColor = "start_color"
        case endColor = "end_color"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        interlocutorFullName = try container.decode(String.self, forKey: .name)
        
        let avatarPath = try? container.decode(String.self, forKey: .avatarUrl)
        interlocutorAvatarUrl = URL(string: avatarPath ?? "")
        
        let genderValue = try container.decode(Int.self, forKey: .gender)
        guard let gender = Gender(rawValue: genderValue) else {
            throw NSError(domain: "Gender not found", code: 404, userInfo: nil)
        }
        self.gender = gender
        
        age = try? container.decode(Int.self, forKey: .age)
        startColor = try? container.decode(String.self, forKey: .startColor)
        endColor = try? container.decode(String.self, forKey: .endColor)
    }
    
    func encode(to encoder: Encoder) throws {}
}
