//
//  DatingUser.swift
//  DatingKit
//
//  Created by Алексей Петров on 30/09/2019.
//

import Foundation

open class DKUserRepository {
    
    private var manager: Manager
    public var userData: UserShow?
    
    init(manager: Manager) {
        self.manager = manager
    }
    
    public func createWithFB(token: String, comletion: @escaping(_ new: Bool, _ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/auth/facebook_login_token",
                                      function: .createFB,
                                      parameters: ["fb_token" : token],
                                      autorepead: false,
                                      needParameters: true)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let createResult: UserCreate = result as! UserCreate
                comletion(createResult.new, createResult.status)
            } else {
                comletion(false, result.status)
            }
        }
    }
    
    public func verify(code: String, email: String, comletion: @escaping(_ new: Bool, _ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/verify_code",
                                      function: .verifyCode,
                                      parameters: ["email" : email,
                                                   "code" : code],
                                      autorepead: true,
                                      needParameters: true)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let createResult: UserCreate = result as! UserCreate
                comletion(createResult.new, createResult.status)
            } else {
                comletion(false, result.status)
            }
        }
    }
    
    public func check(_ completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        
        let task = UserTask(route: "/users/banned",
                            function: .banned,
                            parameters: [String : Any](),
                            autorepead: true,
                            needParameters: false)
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func confirmAge(_ confirm: Bool, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        var request: String = ""
        var userTask: UserTaskTypes
        if confirm {
            request = "/users/consent"
            userTask = .consent
        } else {
            request = "/users/decline"
            userTask = .decline
        }
        let task = UserTask(route: request,
                            function: userTask,
                            parameters: [String : Any](),
                            autorepead: true,
                            needParameters: false)
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func set(birthYear: Int, cityID: Int, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {

        let parameters: [String: Any] = ["city_id": cityID, "birth_year": birthYear]
        
        let task = UserTask(route: "/users/set",
                            function: .setAgeAndCity,
                            parameters: parameters,
                            autorepead: true,
                            needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    func set(gender: Gender, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        
        let parameters: [String: Any] = ["gender" : gender.rawValue]

        let task: UserTask = UserTask(route: "/users/set",
                                      function: .setGender,
                                      parameters: parameters,
                                      autorepead: true,
                                      needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    func set(lookingFor: LookingFor, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/set",
                                      function: .setLookingFor,
                                      parameters: ["looking_for" : lookingFor.rawValue],
                                      autorepead: true,
                                      needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func set(aim: Aim, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/set",
                                      function: .setAim,
                                      parameters: ["aim" : aim.rawValue],
                                      autorepead: true,
                                      needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func set(chatType: ChatType, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/set",
                                      function: .setChatType,
                                      parameters: ["chat_type" : chatType.rawValue],
                                      autorepead: true,
                                      needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func set(photo: Data, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/add_photo",
                                      function: .setPhoto,
                                      parameters: [:],
                                      autorepead: true,
                                      needParameters: false,
                                      bodyParameters: ["photo" : photo])

        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func logout(comletion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task = UserTask(route: "/users/delete_account",
                            function: .logout,
                            parameters: [String : Any](),
                            autorepead: true,
                            needParameters: false)
        manager.takeToWork(task: task) { (result) in
            comletion(result.status)
        }
        
    }
    
    public func randomize(completion: @escaping(_ user: UserShow?, _ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/randomize",
                                      function: .randomize,
                                      parameters: [String : Any](),
                                      autorepead: false,
                                      needParameters: false)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let showResult: UserShow = result as! UserShow
                completion(showResult, showResult.status)
            } else {
                completion(nil, result.status)
            }
        }
    }
    
    func show(completion: @escaping(_ user: UserShow?, _ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/show",
                                      function: .show,
                                      parameters: [String : Any](),
                                      autorepead: true,
                                      needParameters: false)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let showResult: UserShow = result as! UserShow
                self.userData = showResult
                completion(showResult, showResult.status)
            } else if result.status == .noInternetConnection {
                let showResult: UserShow = result as! UserShow
                self.userData = showResult
                completion(showResult, showResult.status)
            } else {
                completion(nil, result.status)
            }
        }
    }
    
    public func generateValidationCode(email: String, comletion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/generate_code",
                                      function: .generateCode,
                                      parameters: ["email" : email],
                                      autorepead: true,
                                      needParameters: true)
        
        manager.takeToWork(task: task) { (result) in
            comletion(result.status)
        }
    }
    
    public func create(email: String, comletion: @escaping(_ new: Bool, _ operationStatus: ResultStatus) -> Void) {
        let task: UserTask = UserTask(route: "/users/create", function: .create, parameters: ["email" : email], autorepead: false, needParameters: true)
        manager.takeToWork(task: task) { (result) in
            if result.status == .succses {
                let createResult: UserCreate = result as! UserCreate
                comletion(createResult.new, createResult.status)
            } else {
                comletion(false, result.status)
            }
        }
    }
    
}

