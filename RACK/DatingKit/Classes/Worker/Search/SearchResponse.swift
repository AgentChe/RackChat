//
//  SearchResponse.swift
//  FAWN
//
//  Created by Алексей Петров on 15/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public struct Match: Response {
    
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var data: MatchetData?
    
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
        data  = try? contanier.decode(MatchetData.self, forKey: .data)
    }
    
}

public struct MatchetData: Decodable {
    public var match: Int
    public var action: Int
    public var matchedUserId: Double
    public var matchedUserName: String
    public var matchedUserPhotosCount: Int
    public var matchedUserPhotos: [String]
    public var matchedUserAge: Int
    public var matchedUserCity: String
    public var matchedAvatarString: String
    public var matchedUserGender: Int
    public var matchedUserAvatarTransparent: String
    public var matchedUserAvatarTransparentHiRes: String
    public var gradientStartColor: String
    public var gradientEndColor: String
    
    enum CodingKeys: String, CodingKey {
        case match
        case action
        case matchedUserId = "matched_user_id"
        case matchedUserName = "matched_user_name"
        case matchedAvatarString = "matched_user_avatar"
        case matchedUserGender = "matched_user_gender"
        case matchedUserAvatarTransparent = "matched_user_avatar_transparent"
        case matchedUserAvatarTransparentHiRes = "matched_user_avatar_transparent_hi_res"
        case matchedUserAvatarStartColor = "matched_user_avatar_start_color"
        case matchedUserAvatarEndColor = "matched_user_avatar_end_color"
        case matchedUserPhotosCount = "matched_user_photos_count"
        case matchedUserPhotos = "matched_user_photos"
        case matchedUserAge = "matched_user_age"
        case matchedUserCity = "matched_user_city"

    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        match = try contanier.decode(Int.self, forKey: .match)
        action = try contanier.decode(Int.self, forKey: .action)
        matchedUserId = try contanier.decode(Double.self, forKey: .matchedUserId)
        matchedUserName = try contanier.decode(String.self, forKey: .matchedUserName)
        matchedAvatarString = try contanier.decode(String.self, forKey: .matchedAvatarString)
        matchedUserGender = try contanier.decode(Int.self, forKey: .matchedUserGender)
        matchedUserAvatarTransparent = try contanier.decode(String.self, forKey: .matchedUserAvatarTransparent)
        matchedUserAvatarTransparentHiRes = try contanier.decode(String.self, forKey: .matchedUserAvatarTransparentHiRes)
        gradientStartColor = try contanier.decode(String.self, forKey: .matchedUserAvatarStartColor)
        gradientEndColor = try contanier.decode(String.self, forKey: .matchedUserAvatarEndColor)
        matchedUserPhotosCount = try contanier.decode(Int.self, forKey: .matchedUserPhotosCount)
        matchedUserPhotos = try contanier.decode([String].self, forKey: .matchedUserPhotos)
        matchedUserAge = try contanier.decode(Int.self, forKey: .matchedUserAge)
        matchedUserCity = try contanier.decode(String.self, forKey: .matchedUserCity)
    }
}

public struct AnswerMatch: Response {
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    
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
    }
}

public struct CheckMatch: Response {
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var partnerId: Double = 0
    public var status: MatchStatus = .waitPartnerAnser
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case partnerId = "partner_id"
        case partnerAnswer = "partner_verdict"
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        if let box = try? contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data) {
            status = MatchStatus(rawValue: try box.decode(Int.self, forKey: .status))!
            partnerId = try box.decode(Double.self, forKey: .partnerId)
        }
        
    }
}
