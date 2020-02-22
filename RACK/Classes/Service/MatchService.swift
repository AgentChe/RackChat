//
//  MatchService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift

final class MatchService {
    static func unmatch(chatId: String) -> Single<Void> {
        let request = UnmatchRequest(userToken: SessionService.userToken, chatId: chatId)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
}
