//
//  User.swift
//  RACK
//
//  Created by Andrey Chernyshev on 11/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSURL

struct User {
    let id: Int
    let gender: Gender
    let lookingFor: LookingFor
    let avatarURL: URL?
    let matchingAvatarURL: URL?
    let name: String
    let email: String
    let age: Int
    let city: String
}

extension User: Model {
    private enum Keys: String, CodingKey {
        case data = "_data"
    }
    
    private enum UserBoxKeys: String, CodingKey {
        case id
        case email
        case name
        case avatar
        case avatarTransparentHiRes = "avatar_transparent_hi_res"
        case lookingFor = "looking_for"
        case gender
        case age
        case city
    }

    init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: Keys.self)
        
        let userBox = try contanier.nestedContainer(keyedBy: UserBoxKeys.self, forKey: .data)
        email = try userBox.decode(String.self, forKey: .email)
        id = try userBox.decode(Int.self, forKey: .id)
        name = try userBox.decode(String.self, forKey: .name)

        let avatarPath = try? userBox.decode(String.self, forKey: .avatar)
        avatarURL = URL(string: avatarPath ?? "")
        
        let avatarMatchingPath = try? userBox.decode(String.self, forKey: .avatarTransparentHiRes)
        matchingAvatarURL = URL(string: avatarMatchingPath ?? "")
        
        let lookingForValue = try? userBox.decode(Int.self, forKey: .lookingFor)
        lookingFor = LookingFor(rawValue: lookingForValue ?? 0) ?? .none
        
        let genderValue = try userBox.decode(Int.self, forKey: .gender)
        guard let gender = Gender(rawValue: genderValue) else {
            throw NSError()
        }
        self.gender = gender
        
        age = try userBox.decode(Int.self, forKey: .age)
        city = (try? userBox.decode(String.self, forKey: .city)) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {}
}
