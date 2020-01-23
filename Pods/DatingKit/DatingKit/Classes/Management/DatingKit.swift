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
    
    public static var chat: Chat {
        return standart.chatManager
    }
    
    public static var search: Search {
        return standart.searchManager
    }
    
    var chatManager: Chat
    var userManager: User
    var searchManager: Search
    
    public var manager: Manager

    init() {
        manager = DKManager(services: [.chats, .notification, .payment, .search, .user, .currentChat, .system])
        userManager = User(manager: manager)
        chatManager = Chat(manager: manager)
        searchManager = Search(manager: manager)
    }
    
    public static func isLogined(comletion: @escaping(_ isLoginned: Bool) -> Void) {
        standart.isLogined(comletion: comletion)
    }
    
    public static func set(locale: String, comletion: @escaping(_ status: ResultStatus) -> Void) {
        standart.set(locale: locale, comletion: comletion)
    }
    
    public static func set(version: Int, market: Int, comletion: @escaping(_ status: ResultStatus) -> Void) {
        standart.set(version: version, market: market, comletion: comletion)
    }
    
    public static func configurate (version: Int, market: Int, comletion: @escaping(_ result: ConfigResult?, _ status: ResultStatus) -> Void) {
        standart.configure(version: version, market: market, comletion: comletion)
    }
    
    public static func deleteCache()  {
        standart.deleteCache()
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
        let task: SystemTask = SystemTask(route: "/users/set_locale",
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
        let task: SystemTask = SystemTask(route: "/users/set_version",
                                          parameters: ["version" : version,
                                                       "market" : market],
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

