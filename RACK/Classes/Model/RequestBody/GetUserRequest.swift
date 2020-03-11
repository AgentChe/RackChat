//
//  GetUserRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 11/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct GetUserRequest: APIRequestBody {
    private let userToken: String
    
    init(userToken: String) {
        self.userToken = userToken
    }
    
    var url: String {
        GlobalDefinitions.Backend.domain + "/api/users/show"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_user_token": userToken,
            "_api_key": GlobalDefinitions.Backend.apiKey
        ]
    }
}
