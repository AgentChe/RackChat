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
        let request = GetChatsRequest(userToken: "bXs6WirVBuOeWSk5HxZt7F6pwHkRRApKRi4JaeVd9e73jyR08TszpvlaXWFmdlCukrSxueFCeJ1pKxNdEuhKiDt4ZKt0WCneVw2reGw5ZufNlhJKByubI51qC3rgoot2")
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { ChatTransformation.from(response: $0) }
    }
}
