//
//  SessionService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

final class SessionService {
    static var userToken: String {
        return CacheTool.shared.getToken()
    }
    
    static func user() -> Single<User?> {
        let request = GetUserRequest(userToken: userToken)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { User.parseFromDictionary(any: $0) }
    }
}
