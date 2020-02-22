//
//  SessionService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

final class SessionService {
    static var userToken: String {
        return CacheTool.shared.getToken()
    }
}
