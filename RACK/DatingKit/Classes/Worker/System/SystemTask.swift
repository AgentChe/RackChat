//
//  SystemTask.swift
//  DatingKit
//
//  Created by Алексей Петров on 30/09/2019.
//

import Foundation

public enum SystemTaskTypes: Int {
    public typealias RawValue = Int
    case setLocale
    case setVersion
    case configuration
    case hasToken
    case deleteCache
    case setConfig
}

open class SystemLogined: Result {
    
    public var status: ResultStatus
    
    public var hasToken: Bool
    
    init(hasToken: Bool, operationStatus: ResultStatus) {
        self.hasToken = hasToken
        status = operationStatus
    }
}

public class ConfigTask: Task {
    
    public var needParameters: Bool
    
    public var route: String
    
    public var service: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus
    
    public var type: Int {
        return userType.rawValue
    }
       
    private var userType: SystemTaskTypes
       
    public var timeConfig: Settings.Timings
    
    init(config: Settings.Timings) {
        needParameters = false
        route = "/users/set"
        autoRepeat = true
        parametrs = [String : Any]()
        userType = .setConfig
        status = .none
        timeConfig = config
        service = Servises.system.stringValue
    }
    
    public func getCurrent<T>() -> T where T : Task {
        return self as! T
    }
    
}

class SystemTask: Task {
    
    public var needParameters: Bool
    
    public var route: String
    
    public var service: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus
    
    public var type: Int {
        return userType.rawValue
    }
    
    private var userType: SystemTaskTypes
    
    init(route: String, parameters:[String : Any], function: SystemTaskTypes, autorepead: Bool, needParameters: Bool) {
        self.autoRepeat = autorepead
        self.needParameters = needParameters
        self.parametrs = parameters
        self.status = .none
        self.route = route
        self.service = Servises.system.stringValue
        self.userType = function
    }
}
