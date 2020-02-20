//
//  GetChatsRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 20/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct GetChatsRequest: APIRequestBody {
    private let userToken: String
    
    init(userToken: String) {
        self.userToken = userToken
    }
    
    var url: String {
        return GlobalDefinitions.ChatService.restDomain + "/api/v1/rooms/getList"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters? {
        return [
            "app_key": GlobalDefinitions.ChatService.appKey,
            "token": userToken
        ]
    }
}
