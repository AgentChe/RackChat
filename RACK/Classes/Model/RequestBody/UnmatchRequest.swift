//
//  UnmatchRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct UnmatchRequest: APIRequestBody {
    private let userToken: String
    private let chatId: String
    
    init(userToken: String, chatId: String) {
        self.userToken = userToken
        self.chatId = chatId
    }
    
    var url: String {
        return GlobalDefinitions.ChatService.restDomain + "/api/v1/rooms/unmatch"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters? {
        return [
            "app_key": GlobalDefinitions.ChatService.appKey,
            "token": userToken,
            "room": chatId
        ]
    }
}
