//
//  ChatsService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 20/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift

final class ChatsService {
    static func getChats() -> Single<[AKChat]> {
        let request = GetChatsRequest(userToken: SessionService.userToken)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { ChatTransformation.from(response: $0) }
    }
}
