//
//  NotificationResponce.swift
//  RACK
//
//  Created by Алексей Петров on 03/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation

struct GetUserTogles: Decodable {
    
    var httpCode: Int
    var message: String
    var needPayment: Bool
    var onMessage: Bool
    var onMatch: Bool
    var onUsers: Bool
    var onKnoks: Bool
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case onMessage = "on_message"
        case onMatch = "on_match"
        case onUsers = "on_users"
        case onKnoks = "on_knocks"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Int.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        let userBox = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        onMessage = try userBox.decode(Int.self, forKey: .onMessage).boolValue
        onMatch = try userBox.decode(Int.self, forKey: .onMatch).boolValue
        onUsers = try userBox.decode(Int.self, forKey: .onUsers).boolValue
        onKnoks = try userBox.decode(Int.self, forKey: .onKnoks).boolValue
        
    }
    
}


extension Int {
    var boolValue: Bool { return self != 0 }
}
