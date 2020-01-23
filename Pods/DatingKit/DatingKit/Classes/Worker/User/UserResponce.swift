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
    public var avatarURLString: String? = ""
    public var name: String
    public var id: Int
    public var avatarTransparent: String? = ""
    public var avatarTransparentHiRes: String? = ""
    
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
        if userBox.contains(.avatar) {
            avatarURLString = try? userBox.decode(String.self, forKey: .avatar)
        }
        if userBox.contains(.avatarTransparent) {
            avatarTransparent = try? userBox.decode(String.self, forKey: .avatarTransparent)
        }
        if userBox.contains(.avatarTransparentHiRes) {
            avatarTransparentHiRes = try? userBox.decode(String.self, forKey: .avatarTransparentHiRes)
        }
        gender = try userBox.decode(Int.self, forKey: .gender)
        lookingFor = try userBox.decode(Int.self, forKey: .lookingFor)
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

struct BannedResponse: Response {
    var httpCode: Double
    var message: String
    var needPayment: Bool
    var isBanned: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case banned
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        let userBox = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        isBanned = try userBox.decode(Bool.self, forKey: .banned)
        
    }
}


