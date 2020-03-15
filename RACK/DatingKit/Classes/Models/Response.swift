//
//  Response.swift
//  FAWN
//
//  Created by Алексей Петров on 31/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
    

struct Token: Response {
    
    var message: String
    
    var needPayment: Bool {
        return false
    }
    
    
    var httpCode: Double
    var token: String
    var new: Bool
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case messgeFromServer = "_msg"
        case data = "_data"
        case token
        case new
    }
    
    init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .messgeFromServer)
        let box = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        token = try box.decodeIfPresent(String.self, forKey: .token)!
        new = try box.decode(Bool.self, forKey: .new)
    }
}

struct TechnicalCreate: Response {
    var message: String
    
    var needPayment: Bool  {
        return false
    }
    
    
    var httpCode: Double
    var new: Bool
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case messgeFromServer = "_msg"
        case data = "_data"
        case new
        case token

    }
    
     init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .messgeFromServer)
        let box = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        new = try box.decode(Bool.self, forKey: .new)
        token = try? box.decode(String.self, forKey: .token)
    }
}

public struct Technical: Response {
    public var message: String
    
    public var needPayment: Bool {
        return false
    }
    
    public var httpCode: Double
    public var isBanned: Bool?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case messgeFromServer = "_msg"
        case data = "_data"
        case banned
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .messgeFromServer)
        
        let box = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        isBanned = try box.decode(Bool.self, forKey: .banned)
    }
}

public struct TechnicalUpload: Response {

    public var message: String
    public var needPayment: Bool { return false }
    public var httpCode: Double
    public var url: String?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case messgeFromServer = "_msg"
        case data = "_data"
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .messgeFromServer)
        
        let box = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        url = try box.decode(String.self, forKey: .url)
    }
}
