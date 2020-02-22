//
//  UserResponce.swift
//  FAWN
//
//  Created by Алексей Петров on 13/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation



public struct UserResponse: Response {
    public var gender: Int
    public var lookingFor: Int
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var email: String
    public var avatarURLString: String = ""
    public var name: String
    public var id: Int
    public var avatarTransparent: String = ""
    public var avatarTransparentHiRes: String = ""
    public var notifyOnMessage: Bool
    public var notifyOnMatch: Bool
    public var notifyOnUsers: Bool
    public var notifyOnKnocks: Bool
    
    public var photosCount: Int
    public var photos: [String]
    public var age: Int
    public var city: String
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case avatarTransparent = "avatar_transparent"
        case avatarTransparentHiRes = "avatar_transparent_hi_res"
        case email
        case id
        case name
        case avatar
        case lookingFor = "looking_for"
        case gender
        case notifyOnMessage = "notify_on_message"
        case notifyOnMatch = "notify_on_match"
        case notifyOnUsers = "notify_on_users"
        case notifyOnKnocks = "notify_on_knocks"

        case photosCount = "photos_count"
        case photos
        case age
        case city
    }

    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        
        let userBox = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        email = try userBox.decode(String.self, forKey: .email)
        id = try userBox.decode(Int.self, forKey: .id)
        name = try userBox.decode(String.self, forKey: .name)

        if let avURLString = try? userBox.decode(String.self, forKey: .avatar) {
             avatarURLString = avURLString
        }

        if let avURLString = try? userBox.decode(String.self, forKey: .avatarTransparent) {
            avatarTransparent = avURLString
        }

        if let avURLString = try? userBox.decode(String.self, forKey: .avatarTransparentHiRes) {
            avatarTransparentHiRes = avURLString
        }
        
        gender = try userBox.decode(Int.self, forKey: .gender)
        lookingFor = try userBox.decode(Int.self, forKey: .lookingFor)
        notifyOnMessage = try userBox.decode(Int.self, forKey: .notifyOnMessage).boolValue
        notifyOnMatch = try userBox.decode(Int.self, forKey: .notifyOnMatch).boolValue
        notifyOnUsers = try userBox.decode(Int.self, forKey: .notifyOnUsers).boolValue
        notifyOnKnocks = try userBox.decode(Int.self, forKey: .notifyOnKnocks).boolValue
        
        photosCount = try userBox.decode(Int.self, forKey: .photosCount)
        photos = try userBox.decode([String].self, forKey: .photos)
        age = try userBox.decode(Int.self, forKey: .age)
        city = try userBox.decode(String.self, forKey: .city)
    }
    
    
}


public struct UserRandomize: Response {
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var avatarURLString: String
    public var matchingAvatarURLString: String
    
    public var name: String
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case name
        case avatar
        case matchingAvatar = "avatar_transparent_hi_res"
        
    }
    
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        let userBox = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try userBox.decode(String.self, forKey: .name)
        avatarURLString = try userBox.decode(String.self, forKey: .avatar)
        matchingAvatarURLString = try userBox.decode(String.self, forKey: .matchingAvatar)
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}
