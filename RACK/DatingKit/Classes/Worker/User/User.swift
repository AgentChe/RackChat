//
//  File.swift
//  FAWN
//
//  Created by Алексей Петров on 16/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import RealmSwift
import FBSDKCoreKit
import FBSDKLoginKit
import Reachability
import PromiseKit

public enum LookingFor: Int {
    case none = 0
    case guys = 1
    case girls = 2
    case any = 3
}

public enum Aim: Int {
    case chats = 1
    case virt = 2
    case meetUps = 3
}

public enum ChatType: Int {
    case text = 1
    case image = 2
}

class CheckRequest: APIRequest {
    
    var url: String {
        return "/users/banned"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init() {
        parameters = [String : Any]()
    }
    
    func parse(data: Data) -> Response! {
        do {
            let response: BannedResponse = try JSONDecoder().decode(BannedResponse.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}

open class UserShow: Result {
    public var status: ResultStatus
    public var gender: Gender
    public var avatarURL: String
    public var matchingAvatarURL: String
    public var name: String
    public var email: String
    public var id: Int
    public var age: Int
    public var city: String

    init(realm: UserRealm, status:ResultStatus) {
        self.status = status
        avatarURL = realm.avatarURLString
        matchingAvatarURL = realm.matchingAvatarURL
        name = realm.name
        email = realm.email
        gender = Gender(rawValue: (realm.gender.value!))!
        id = realm.id
        age = realm.age
        city = realm.city
    }
    
    init(response: UserResponse, status:ResultStatus ) {
        self.status = status
        if let url: String = response.avatarURLString {
             avatarURL = url
        } else {
             avatarURL = ""
        }
        
        if let urlHiRes: String = response.avatarTransparentHiRes {
            matchingAvatarURL = urlHiRes
        } else {
            matchingAvatarURL = ""
        }
        name = response.name
        gender = Gender(rawValue: response.gender)!
        email = response.email
        id = response.id
        age = response.age
        city = response.city
    }
    
}

open class UserVerify: Result {
    
    public var status: ResultStatus
    public var succses: Bool
    public var new: Bool
    
    init(succses: Bool, new: Bool, operationStatus: ResultStatus) {
        self.new = new
        self.succses = succses
        status = operationStatus
    }
}

open class UserCreate: Result {
    
    public var status: ResultStatus
    
    public var new: Bool
    
    init(new: Bool, operationStatus: ResultStatus) {
        self.new = new
        status = operationStatus
    }
    
}

open class UserWorker: Worker {
    
    public var currentTaskStatus: TaskStatus {
        return status
    }
    
    private let manager: Manager
    private var status: TaskStatus = .waiting
    private let requestTool: RequestTool
    private let cacheTool: CacheTool
    private let errorTool: ErrorTool
    
    private let technicalParcer: (_ data: Data) -> Response? =  { (_ data: Data) in
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    init(manager: Manager, requestManager: RequestTool, cacheManager: CacheTool, errorTool: ErrorTool) {
        self.errorTool = errorTool
        self.manager = manager
        self.requestTool = requestManager
        self.cacheTool = cacheManager
        
        if cacheTool.getToken() == "" {
            cacheTool.removeCache()
        }
    }

    public func canProcess() -> Bool {
        return true
    }
    
    public func perfom(task: TrakerTask) {
        let userTaskType: UserTaskTypes = UserTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        switch userTaskType {
            
        case .none:
            task.handler(SystemResult(status: .none))
        case .show:
            show(task: trakerTask)
            break
        case .create:
            create(task: task)
            break
        case .generateCode:
            generateCode(task: task)
            break
        case .verifyCode:
            verifyCode(task: task)
            break
        case .setGender, .setAim, .setChatType, .setLookingFor, .consent, .decline, .setAgeAndCity:
            setupUser(task: task)
            break
        case .randomize:
            randomize(task: task)
            break
        case .logout:
            logout(task: task)
            break
        case .deleteAccount:
            break
        case .banned:
            CheckUser(task: task)
            break
        case .createFB:
            createFromFB(task: task)
            break
        }

    }
    
    private func checkUser() -> Promise<ResultStatus> {
        return Promise<ResultStatus> { [weak self] seal in
            self?.requestTool.requset(CheckRequest(), completion: { (result) in
                if result != nil {
                    let data: BannedResponse = result as! BannedResponse
                    if data.httpCode == 200 {
                        if data.isBanned {
                            seal.fulfill(.banned)
                        } else {
                            seal.fulfill(.succses)
                        }
                    } else {
                        seal.fulfill(.undifferentError)
                    }
                } else {
                    seal.fulfill(.undifferentError)
                }
            })
            
        }
        
    }
    
    private func CheckUser(task: TrakerTask) {
        _ = checkUser().done { [weak self] (status) in
            self?.close(task: task, with: SystemResult(status: status), task: .done)
        }
    }
    
    private func rand(task: TrakerTask) -> Promise<UserRandomize?> {
        let currentTask: TrakerTask = task
        return Promise<UserRandomize?> { [weak self] seal in
            requestTool.request(route: task.userTask.route,
                                parameters: task.userTask.parametrs,
                                useToken: true,
                                parcer: { (data) -> Response? in
                                    do {
                                        let response: UserRandomize = try JSONDecoder().decode(UserRandomize.self, from: data)
                                        return response
                                    } catch let error {
                                        debugPrint(error.localizedDescription)
                                        _ = self?.errorTool.validate(responce: nil, task: currentTask)
                                        return nil
                                    }
            }, completion: { (result) in
                if (self?.errorTool.validate(responce: result, task: currentTask))! {
                    let responce: UserRandomize = result as! UserRandomize
                    seal.fulfill(responce)
                } else {
                    seal.fulfill(nil)
                }
                
            })
        }
    }
    
    private func system(result: Response!, for currentTask: TrakerTask) {
        if errorTool.validate(responce: result, task: currentTask) {
            close(task: currentTask, with: SystemResult(status: .succses), task: .done)
        }
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    private func logout(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: technicalParcer)
        { [weak self] (result) in
            self?.cacheTool.removeCache()
            self?.system(result: result, for: task)
        }
    }
    
    private func setupUser(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: technicalParcer)
        { [weak self] (result) in
            self?.system(result: result, for: task)
        }
    }
    
    private func randomize(task: TrakerTask) {
        
        var currentTask: TrakerTask = task
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: currentTask,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failed)
            return
        }
        
        _ = firstly {[weak self] in
            self!.rand(task: currentTask)
            }.done { [weak self] (userRand) in
                if (self?.errorTool.validate(responce: userRand, task: currentTask))! {
                    self!.cacheTool.updateUser(randInfo: userRand!)
                    if self!.cacheTool.getUser() != nil {
                        let userRealm: UserShow = self!.cacheTool.getUser()
                        currentTask.status = .done
                        self!.manager.traker.close(trakerTask: currentTask)
                        currentTask.handler(userRealm)
                        return
                    } else {
                        self?.errorTool.postError(task: currentTask,
                                                  result: SystemResult(status: .undifferentError),
                                                  messsage: "cashe data is nil!, please use chek creating cache for User!",
                                                  status: .failed)
                    }
                }
        }
        
    }
    
    private func createFromFB(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: UserCreate(new: false, operationStatus: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route, parameters: task.userTask.parametrs, useToken: false, parcer: { (data) -> Response? in
            do {
                let response: Token = try JSONDecoder().decode(Token.self, from: data)
                return response
            } catch let error {
                _ = self.errorTool.validate(responce: nil, task: task)
                debugPrint(error.localizedDescription)
                return nil
            }
        }) { [weak self] (response) in
                if (self?.errorTool.validate(responce: response, task: task))! {
                    let techResult: Token = (response as? Token)!
                    self?.cacheTool.saveToken(token: techResult.token)
                    _ = self?.checkUser().done({ (status) in
                        if techResult.token != "" {
                            self?.close(task: task, with: UserCreate(new: techResult.new, operationStatus: status), task: .done)
                        } else {
                            self?.errorTool.postError(task: task,
                                                      result: UserCreate(new: false, operationStatus: .undifferentError),
                                                      messsage: "empty Token",
                                                      status: .failed)
                        }
                    })
                }
        }
    }

    private func show(task: TrakerTask) {
        
        var currentTask: TrakerTask = task
        
        if cacheTool.getToken() == "" {
            errorTool.postError(task: currentTask,
                                result: SystemResult(status: .notLogined),
                                messsage: "User not Logined",
                                status: .failed)
            return
        }
        
        if NetworkState.isConnected() == false {
           
            if let userRealm: UserShow = cacheTool.getUser() {
                currentTask.status = .done
                self.manager.traker.close(trakerTask: currentTask)
                userRealm.status = .noInternetConnection
                currentTask.handler(userRealm)
                print("User load from cache")
                return
            } else {
                errorTool.postError(task: currentTask,
                                    result: SystemResult(status: .noInternetConnection),
                                    messsage: "No internet Connection",
                                    status: .failedFromInternetConnection)
                return
            }
        }
        
        if let userRealm: UserShow = cacheTool.getUser() {
            currentTask.status = .done
            self.manager.traker.close(trakerTask: currentTask)
            currentTask.handler(userRealm)
            print("User load from cache")
            
            return
        }
        
        requestTool.request(route: currentTask.userTask.route,
                            parameters: currentTask.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
            do {
                let response: UserResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                return response
            } catch let error {
                _ = self.errorTool.validate(responce: nil, task: currentTask)
                debugPrint(error.localizedDescription)
                return nil
            }
        }) { [weak self] (result) in
            if (self?.errorTool.validate(responce: result, task: currentTask))! {
                let userResponse: UserResponse = result as! UserResponse
                let user: UserShow = UserShow(response: userResponse, status: .succses)
                currentTask.handler(user)
                print("User load from network")
                
                self!.cacheTool.saveUser(user: userResponse)
                            
                self!.close(task: currentTask, with: user, task: .done)
            }
        }
        
    }
    
    private func generateCode(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: UserCreate(new: false, operationStatus: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
    
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: false,
                            parcer: technicalParcer) { [weak self] (result) in
                                if (self?.errorTool.validate(responce: result, task: task))! {
                                    task.handler(SystemResult(status: .succses))
                                    self?.close(task: task, with: SystemResult(status: .succses), task: .done)
                                }
        }
    }
    
    private func verifyCode(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: UserCreate(new: false, operationStatus: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: false,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: Token = try JSONDecoder().decode(Token.self, from: data)
                                    return response
                                } catch let error {
                                    _ = self.errorTool.validate(responce: nil, task: task)
                                    debugPrint(error.localizedDescription)
                                    return nil
                                }
        }) { [weak self] (result) in
            
            if (self?.errorTool.validate(responce: result, task: task))! {
                let token: Token = result as! Token
                self?.cacheTool.saveToken(token: token.token)
                _ = self?.checkUser().done({ (status) in
                    if token.token != "" {
                        
                        self?.close(task: task, with: UserCreate(new: token.new, operationStatus: status), task: .done)
                    } else {
                        self?.errorTool.postError(task: task,
                                                  result: UserCreate(new: false, operationStatus: .undifferentError),
                                                  messsage: "empty Token",
                                                  status: .failed)
                    }
                })
            }
        }
        
    }
    
    private func create(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: UserCreate(new: false, operationStatus: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route, parameters: task.userTask.parametrs, useToken: false, parcer: { (data) -> Response? in
            do {
                let response: TechnicalCreate = try JSONDecoder().decode(TechnicalCreate.self, from: data)
                return response
            } catch let error {
                _ = self.errorTool.validate(responce: nil, task: task)
                debugPrint(error.localizedDescription)
                return nil
            }
        }) { [weak self] (response) in
            if (self?.errorTool.validate(responce: response, task: task))! {
                let techResult: TechnicalCreate = (response as? TechnicalCreate)!
                if techResult.token != nil {
                    self?.cacheTool.saveToken(token: techResult.token!)
                    _ = self?.checkUser().done({ (status) in
                        if techResult.token != "" {
                            self?.close(task: task, with: UserCreate(new: techResult.new, operationStatus: status), task: .done)
                        } else {
                            self?.errorTool.postError(task: task,
                                                      result: UserCreate(new: false, operationStatus: .undifferentError),
                                                      messsage: "empty Token",
                                                      status: .failed)
                        }
                    })
                } else {
                    self?.close(task: task, with: UserCreate(new: techResult.new, operationStatus: .succses), task: .done)
                }
            }
        }
    }
    
}
