//
//  User+Extention.swift
//  RACK
//
//  Created by Алексей Петров on 24/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import DatingKit


enum GenderType: Int {
    case man = 1
    case woman = 2
}

//enum LookingFor: Int {
//    case man = 1
//    case woman = 2
//    case any = 3
//}

//enum Aim: Int {
//    case chats = 1
//    case virt = 2
//    case meetUps = 3
//}
//
//enum ChatType: Int {
//    case text = 1
//    case image = 2
//}


//{
//    "_code": 200,
//    "_msg": "OK",
//    "_need_payment": false,
//    "_data": {
//        "banned": true
//    }
//}

struct BannedResponse: Decodable {
    
    var httpCode: Int
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
        httpCode = try contanier.decode(Int.self, forKey: .httpCode)
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
    
    init(gender: GenderType) {
        parameters = ["gender" : gender.rawValue]
    }
    
}

//extension User {
//
//    static let genderKey: String = "current_gender"
//    static let lookingForKey: String = "looking_for"
//
//    func checkUser(_ completion: @escaping(_ banned: Bool) -> Void) {
//        if self.tokenForVerify() != "" {
//            let request: AskForBanned = AskForBanned(token: self.tokenForVerify())
//            RequestManager.shared.requset(request) { (response) in
//                if response != nil {
//                    if let banned: BannedResponse = response as! BannedResponse {
//                        if banned.httpCode == 200 {
//                            completion(banned.isBanned)
//                        } else {
//                            completion(false)
//                        }
//                    } else {
//                        completion(false)
//                    }
//                } else {
//                    completion(false)
//                }
//            }
//
//        } else {
//            completion(false)
//        }
//
//    }
//
//    func confirmAge(_ confirm: Bool) {
//        if confirm {
//            let request: Consent = Consent()
//            RequestManager.shared.requset(request) { (result) in
//
//            }
//        } else {
//            let request: Decline = Decline()
//            RequestManager.shared.requset(request) { (result) in
//
//            }
//        }
//    }
//
//    func set(gender: GenderType, completion: @escaping() -> Void) {
//        if  gender == .man {
//            if CurrentAppConfig.shared.showIfMaleRegistration {
//                CurrentAppConfig.shared.showUponRegistration = true
//            } else {
//                CurrentAppConfig.shared.showUponRegistration = false
//            }
//        }
//        if  gender == .woman {
//            if CurrentAppConfig.shared.showIfFemaleRegistration {
//                CurrentAppConfig.shared.showUponRegistration = true
//            } else {
//                 CurrentAppConfig.shared.showUponRegistration = false
//            }
//        }
//
//
//        let request: SetGender = SetGender(gender: gender)
//
//        UserDefaults.standard.set(gender.rawValue, forKey: User.genderKey)
//        RequestManager.shared.requset(request) { (result) in
//            let techResult: Technical = result as! Technical
//            if techResult.httpCode == 200 {
//                self.loadUser()
//            }
//           completion()
//        }
//    }
//
//    func set(lookingFor: LookingFor, completion: @escaping() -> Void) {
//        let request: SetLookingFor = SetLookingFor(lookingFor: lookingFor)
//        UserDefaults.standard.set(lookingFor.rawValue, forKey: User.lookingForKey)
//        RequestManager.shared.requset(request) { (result) in
//            completion()
//        }
//    }
//
//    func set(aim: Aim, completion: @escaping() -> Void) {
//        let request: SetAim = SetAim(aim: aim)
//        RequestManager.shared.requset(request) { (result) in
//            completion()
//        }
//    }
//
//    func set(chatType: ChatType, completion: @escaping() -> Void) {
//        let request: SetChatType = SetChatType(chatType: chatType)
//        RequestManager.shared.requset(request) { (result) in
//            completion()
//        }
//    }
//}
