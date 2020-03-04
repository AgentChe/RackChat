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
    
    public static var user: User {
        return standart.userManager
    }
    
    public static var search: Search {
        return standart.searchManager
    }

    public static var cities: Cities {
        return standart.citiesManager
    }

    var userManager: User
    var searchManager: Search
    var citiesManager: Cities

    public var manager: Manager
    
    private let servicesList: [Servises] = [.notification, .payment, .search, .user, .system, .marketing, .cities]

    init() {
        manager = DKManager(services: servicesList)
        userManager = User(manager: manager)
        searchManager = Search(manager: manager)
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
    
    @available(*, deprecated, message: "use DatingKit.config")
    public static func configurate (version: Int, market: Int, comletion: @escaping(_ result: ConfigResult?, _ status: ResultStatus) -> Void) {
        standart.configure(version: version, market: market, comletion: comletion)
    }
    
    public static func deleteCache()  {
        standart.deleteCache()
    }
    
    public static func config(timings:Settings.Timings  ,_ config: @escaping(_ status: ResultStatus) -> Void) {
        standart.config(timings: timings, config)
    }
    
    public static func setADV(_ completion:@escaping(_ ads: [String: Any]?) -> Void) {
        standart.setADV(completion)
    }
    
    public static func updateADV(storeCountry: String, _ completion: @escaping(_ status: ResultStatus) -> Void) {
        standart.updateADV(storeCountry: storeCountry, completion)
    }
    
    public static func coldStart(storeCountry: String,_ completion: @escaping(_ status: ResultStatus) -> Void) {
        standart.coldStart(storeCountry: storeCountry, completion)
    }
    
    func coldStart(storeCountry: String,_ completion: @escaping(_ status: ResultStatus) -> Void) {
        let task: MarketingTask = MarketingTask(storyCountry: storeCountry)
        manager.takeToWork(task: task) { (result) in
            debugPrint(result.status)
            completion(result.status)
        }
    }
    
    func setADV(_ completion:@escaping(_ ads: [String: Any]?) -> Void) {
        let task: MarketingTask = MarketingTask(type: .setAdAtributes)
        manager.takeToWork(task: task) { (result) in
            guard let responce: MarketingResult = result as? MarketingResult else { return }
            completion(responce.ads)
        }
    }
    
    func updateADV(storeCountry: String, _ completion: @escaping(_ status: ResultStatus) -> Void) {
        let task: MarketingTask = MarketingTask(type: .confirmAdAtributes, storeCountry: storeCountry)
        manager.takeToWork(task: task) { (result) in
            debugPrint(result.status)
            completion(result.status)
        }
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
    
    func configure(version: Int, market: Int, comletion: @escaping(_ result: ConfigResult?, _ status: ResultStatus) -> Void) {
        let task: SystemTask = SystemTask(route: "/configuration",
                                          parameters: ["version" : version,
                                                       "market" : market],
                                          function: .configuration,
                                          autorepead: true,
                                          needParameters: true)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let config: ConfigResult = result as! ConfigResult
                comletion(config, config.status)
            } else {
                comletion(nil, result.status)
            }
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

