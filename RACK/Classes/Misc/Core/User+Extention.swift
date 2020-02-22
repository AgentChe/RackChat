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

class AskForBanned: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/banned"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return false
    }
    
    init(token: String) {
        parameters = ["_user_token" : token]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: BannedResponse = try JSONDecoder().decode(BannedResponse.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}

class Decline: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/decline"
    }
    
    var parameters: [String : Any] {
        return [String : Any]()
    }
    
    var useToken: Bool {
        return true
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}

class Consent: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/consent"
    }
    
    var parameters: [String : Any] {
        return [String : Any]()
    }
    
    var useToken: Bool {
        return true
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    
}

class SetChatType: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/set_chat_type"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(chatType: ChatType) {
        parameters = ["chat_type" : chatType.rawValue]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    
}

class SetAim: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/set_aim"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(aim: Aim) {
        parameters = ["aim" : aim.rawValue]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}

class SetLookingFor: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/set_looking_for"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(lookingFor: LookingFor) {
        parameters = ["looking_for" : lookingFor.rawValue]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}

class SetGender: APIRequest {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/set_gender"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    init(gender: AKGender) {
        parameters = ["gender" : gender.rawValue]
    }
    
}
