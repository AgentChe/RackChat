//
//  MatchTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 06/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSJSONSerialization

typealias SearchingQueueUUID = String

final class MatchTransformation {
    static func from(matchWebSocket response: String) -> MatchService.Event? {
        guard
            let jsonData = response.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
            let result = json["result"] as? [String: Any],
            let action = result["action"] as? String
        else {
            return nil
        }
        
        switch action {
        case "register":
            guard let uuidQueue = result["result"] as? String else {
                return nil
            }
            
            return .registered(uuidQueue)
        case "match":
            guard let info = result["result"] as? [[String: Any]] else {
                return nil
            }
            
            return .matchProposed(MatchProposed())
        case "skip":
            return .refused
        case "room":
            return .coupleFormed
        default:
            return nil
        }
    }
}
