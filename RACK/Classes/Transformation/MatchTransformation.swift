//
//  MatchTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 06/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSJSONSerialization

typealias SearchingQueueId = String

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
            
            let array = ProposedInterlocutor.parseFromArray(any: info)
            
            return .proposedInterlocutor(array)
        case "skip":
            guard let info = result["result"] as? [[String: Any]] else {
                return nil
            }
            
            let array: [SearchingQueueId] = info.compactMap {
                guard let queueId = $0["queue_id"] as? String else {
                    return nil
                }
                
                return queueId
            }
            
            return .proposedInterlocutorRefused(array)
        case "sure":
            guard let info = result["result"] as? [[String: Any]] else {
                return nil
            }
            
            let array: [(SearchingQueueId, Int)] = info.compactMap {
                guard let queueId = $0["queue_id"] as? String, let timeOut = $0["timeout"] as? Int else {
                    return nil
                }
                
                return (queueId, timeOut)
            }
            
            return .proposedInterlocutorConfirmed(array)
        case "room":
            guard let info = result["result"] as? [[String: Any]] else {
                return nil
            }
            
            let array: [SearchingQueueId] = info.compactMap {
                guard let queueId = $0["queue_id"] as? String else {
                    return nil
                }
                
                return queueId
            }
            
            return .coupleFormed(array)
        case "close":
            guard let info = result["result"] as? [[String: Any]] else {
                return nil
            }
            
            let array: [SearchingQueueId] = info.compactMap {
                guard let queueId = $0["queue_id"] as? String else {
                    return nil
                }
                
                return queueId
            }
            
            return .closed(array)
        default:
            return nil
        }
    }
}
