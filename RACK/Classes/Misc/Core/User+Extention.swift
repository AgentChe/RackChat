//
//  User+Extention.swift
//  RACK
//
//  Created by Алексей Петров on 24/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation

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
