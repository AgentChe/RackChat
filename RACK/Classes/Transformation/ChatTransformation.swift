//
//  ChatTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 21/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSJSONSerialization

final class ChatTransformation {
    static func from(response: Any) -> [AKChat] {
        guard let json = response as? [String: Any], let result = json["result"] as? [[String: Any]] else {
            return []
        }
        
        return result.compactMap { AKChat.parseFromDictionary(any: $0) }
    }
    
    static func from(webSocket response: String) -> ChatService.Event? {
        guard
            let jsonData = response.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
            let result = json["result"] as? [String: Any],
            let action = result["action"] as? String
        else {
            return nil
        }
        
        switch action {
        case "message":
            guard let data = result["result"] as? [String: Any], let message = AKMessage.parseFromDictionary(any: data) else {
                return nil
            }
            
            return .newMessage(message)
        default:
            return nil
        }
    }
}
