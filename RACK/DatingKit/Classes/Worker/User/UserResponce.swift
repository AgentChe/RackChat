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
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var email: String
    public var avatarURLString: String = ""
    public var name: String
    public var id: Int
    public var avatarTransparent: String = ""
    public var avatarTransparentHiRes: String = ""
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
        case gender
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
        
        age = try userBox.decode(Int.self, forKey: .age)
        city = (try? userBox.decode(String.self, forKey: .city)) ?? ""
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
