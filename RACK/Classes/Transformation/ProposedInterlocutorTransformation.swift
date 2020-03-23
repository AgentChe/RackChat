//
//  ProposedInterlocutorTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

final class ProposedInterlocutorTransformation {
    static func from(response: Any) -> [ProposedInterlocutor] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { ProposedInterlocutor.parseFromDictionary(any: $0) }
    }
}
