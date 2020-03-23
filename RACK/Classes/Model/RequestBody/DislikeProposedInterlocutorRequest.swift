//
//  DislikeProposedInterlocutorRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct DislikeProposedInterlocutorRequest: APIRequestBody {
    private let userToken: String
    private let proposedInterlocutorId: Int
    
    init(userToken: String, proposedInterlocutorId: Int) {
        self.userToken = userToken
        self.proposedInterlocutorId = proposedInterlocutorId
    }
    
    var url: String {
        GlobalDefinitions.Backend.domain + "/api/feed/dislike"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.Backend.apiKey,
            "_user_token": userToken,
            "target_user_id": proposedInterlocutorId
        ]
    }
}
