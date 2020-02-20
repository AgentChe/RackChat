//
//  ChatTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 21/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

final class ChatTransformation {
    static func from(response: Any) -> [AKChat] {
        guard let json = response as? [String: Any], let result = json["result"] as? [[String: Any]] else {
            return []
        }
        
        return result.compactMap { AKChat.parseFromDictionary(any: $0) }
    }
}
