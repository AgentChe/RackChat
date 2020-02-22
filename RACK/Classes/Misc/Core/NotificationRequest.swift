//
//  NotificationRequest.swift
//  RACK
//
//  Created by Алексей Петров on 03/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation

class NotificationSetKey: APIRequestV1 {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/notifications/set_key"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(parameters: [String : Any]) {
        self.parameters = parameters
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

class NotificationToggle: APIRequestV1 {
    
    var url: String {
        return "/notifications/toggle"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool = true
    
    init(onMessages: Bool) {
        parameters = ["on_message" : onMessages]
    }
    
    init(onMatch: Bool) {
        parameters = ["on_match" : onMatch]
    }
    
    init(onUsers: Bool) {
        parameters = ["on_users" : onUsers]
    }
    
    init(onKnocks: Bool) {
        parameters = ["on_knocks" : onKnocks]
    }
    
    init(onMessages: Bool, onMatch: Bool, onUsers: Bool, onKnocks: Bool) {
        parameters = ["on_message" : onMessages,
                      "on_match" : onMatch,
                      "on_users" : onUsers,
                      "on_knocks" : onKnocks]
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



class NotificationRegister: APIRequestV1 {
    var url: String {
        return "/notifications/register"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(type: PushType) {
        parameters = ["type" : "\(type.rawValue)"]
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

class NotificationGet: APIRequestV1 {
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/notifications/get"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool = true
    
    init() {
        parameters = [String : Any]()
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: GetUserTogles = try JSONDecoder().decode(GetUserTogles.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}
