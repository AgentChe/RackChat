//
//  GetProposedInterlocutorsRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct GetProposedInterlocutorsRequest: APIRequestBody {
    private let userToken: String
    
    init(userToken: String) {
        self.userToken = userToken
    }
    
    var url: String {
        GlobalDefinitions.Backend.domain + "/api/feed/list"
    }
    
    var method: HTTPMethod {
        .post 
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.Backend.apiKey,
            "_user_token": userToken
        ]
    }
}
