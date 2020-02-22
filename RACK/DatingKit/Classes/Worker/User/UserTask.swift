//
//  UserTask.swift
//  DatingKit
//
//  Created by Алексей Петров on 24/09/2019.
//

import Foundation

public enum UserTaskTypes: Int {
    case none
    case show
    case create
    case generateCode
    case verifyCode
    case setGender
    case setAgeAndCity
    case setLookingFor
    case setAim
    case setChatType
    case randomize
    case logout
    case deleteAccount
    case consent
    case decline
    case banned
    case createFB
}

open class UserTask: Task {
    
    public var service: String
    
    public var needParameters: Bool
    
    public var route: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus
    
    public var type: Int {
        return userType.rawValue
    }
    
    private var userType: UserTaskTypes
    
    init(route: String, function: UserTaskTypes, parameters: [String : Any], autorepead: Bool, needParameters: Bool) {
        self.route = route
        self.service = Servises.user.stringValue
        self.parametrs = parameters
        self.status = .none
        self.userType = function
        self.autoRepeat = autorepead
        self.needParameters = needParameters
    }
    
    
}
