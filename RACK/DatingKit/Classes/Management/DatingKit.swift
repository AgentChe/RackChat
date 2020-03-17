//
//  Owner.swift
//  DatingKit
//
//  Created by Алексей Петров on 24/09/2019.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

open class DatingKit: Owner {
    
    static let standart: DatingKit = DatingKit()
    
    public static var user: DKUserRepository {
        return standart.userManager
    }

    public static var cities: Cities {
        return standart.citiesManager
    }

    var userManager: DKUserRepository
    var citiesManager: Cities

    public var manager: Manager
    
    private let servicesList: [Servises] = [.notification, .payment, .user, .system, .cities]

    init() {
        manager = DKManager(services: servicesList)
        userManager = DKUserRepository(manager: manager)
        citiesManager = Cities(manager: manager)
    }
    
    public static func isLogined(comletion: @escaping(_ isLoginned: Bool) -> Void) {
        standart.isLogined(comletion: comletion)
    }
    
    @available(*, deprecated, message: "use another methods")
    public static func set(locale: String, comletion: @escaping(_ status: ResultStatus) -> Void) {
        standart.set(locale: locale, comletion: comletion)
    }
    
    
    @available(*, deprecated, message: "use another methods")
    public static func set(version: Int, market: Int, comletion: @escaping(_ status: ResultStatus) -> Void) {
        standart.set(version: version, market: market, comletion: comletion)
    }
    
    public static func deleteCache()  {
        standart.deleteCache()
    }
    
    public static func config(timings:Settings.Timings  ,_ config: @escaping(_ status: ResultStatus) -> Void) {
        standart.config(timings: timings, config)
    }
    
    func config(timings:Settings.Timings  ,_ config: @escaping(_ status: ResultStatus) -> Void) {
        let task: ConfigTask = ConfigTask(config: timings)
        manager.takeToWork(task: task) { (result) in
            config(result.status)
        }
    }
    
    func deleteCache() {
        let task: SystemTask = SystemTask(route: "",
                                          parameters: [String : Any](),
                                          function: .deleteCache,
                                          autorepead: false,
                                          needParameters: false)
        manager.takeToWork(task: task) { (result) in
            
        }
    }
    
    
    func set(locale: String, comletion: @escaping(_ status: ResultStatus) -> Void) {
        let task: SystemTask = SystemTask(route: "/users/set",
                                          parameters: ["locale" : locale],
                                          function: .configuration,
                                          autorepead: true,
                                          needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            comletion(result.status)
        }
        
    }
    
    func set(version: Int, market: Int, comletion: @escaping(_ status: ResultStatus) -> Void) {
        let task: SystemTask = SystemTask(route: "/users/set",
                                          parameters: ["version" : version,
                                                       "market" : market,
                                                       "timezone" : Settings.localTimeZoneAbbreviation],
                                          function: .setVersion,
                                          autorepead: true,
                                          needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            comletion(result.status)
        }
    }
    
    func isLogined(comletion: @escaping(_ isLoginned: Bool) -> Void) {
        
        let task: SystemTask = SystemTask(route: "",
                                        parameters: [String : Any](),
                                        function: .hasToken,
                                        autorepead: false,
                                        needParameters: false)
        
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                if let logginedResult: SystemLogined = result as! SystemLogined {
                    comletion(logginedResult.hasToken)
                } else {
                    comletion (false)
                }
            } else {
                comletion(false)
            }
        }
    }
}

