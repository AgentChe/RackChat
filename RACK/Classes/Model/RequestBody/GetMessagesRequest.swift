//
//  GetMessagesRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 24/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct GetMessagesRequest: APIRequestBody {
    private let userToken: String
    private let chatId: String
    private let page: Int
    
    init(userToken: String, chatId: String, page: Int) {
        self.userToken = userToken
        self.chatId = chatId
        self.page = page
    }
    
    var url: String {
        return GlobalDefinitions.ChatService.restDomain + "/api/v1/rooms/getRoom"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters? {
        return [
            "app_key": GlobalDefinitions.ChatService.appKey,
            "token": userToken,
            "room": chatId,
            "page": page
        ]
    }
}
