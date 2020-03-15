//
//  System.swift
//  DatingKit
//
//  Created by Алексей Петров on 30/09/2019.
//

import Foundation

open class ConfigResult: Result {
    
    public var status: ResultStatus
    
    public var needShowPaygateGirl: Bool
    public var needShowPaygateGuy: Bool
    
    init(config: SystemConfiguration, status: ResultStatus) {
        
        self.status = status
        
        needShowPaygateGirl = config.showFemale
        needShowPaygateGuy = config.showMale
    }
}

open class SystemWorker: Worker {
    
    private let cacheTool: CacheTool
    private let errorTool: ErrorTool
    private let requestTool: RequestTool
    private let manager: Manager
    private let technicalParcer: (_ data: Data) -> Response? =  { (_ data: Data) in
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    init(manager: Manager, cache: CacheTool, error: ErrorTool, request: RequestTool) {
        self.cacheTool = cache
        self.requestTool = request
        self.errorTool = error
        self.manager = manager
    }
    
    public var currentTaskStatus: TaskStatus {
        return .none
    }
    
    public func canProcess() -> Bool {
        return true
    }
    
    public func perfom(task: TrakerTask) {
        let systemTaskType: SystemTaskTypes = SystemTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        switch systemTaskType {
        case .setLocale:
            set(task: task)
        case .setVersion:
            set(task: task)
        case .configuration:
            configure(task: task)
        case .hasToken:
            task.handler(hasToken(task: task))
        case .deleteCache:
            deleteCache(task: task)
        case .setConfig:
            setConfig(task: task)
        }
    }
    
    func setConfig(task: TrakerTask) {
        let configTask: ConfigTask = task.userTask.getCurrent()
        
        Settings.set(times: configTask.timeConfig, autoSettings: true, bundle: "")
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        var parameters: [String : Any] = ["version" : Int(Settings.currentBundle)!,
                                          "market" : 1]
        
        requestTool.request(route: "/configuration", parameters: parameters, useToken: true, parcer: { (data) -> Response? in
            do {
                let response: SystemConfiguration = try JSONDecoder().decode(SystemConfiguration.self, from: data)
                return response
            } catch let error {
                _ = self.errorTool.validate(responce: nil, task: task)
                self.errorTool.postError(task: task,
                                         result: SystemResult(status: .undifferentError),
                                         messsage: error.localizedDescription,
                                         status: .failed)
                                        return nil
            }
       
        }) { (responce) in
            if (self.errorTool.validate(responce: responce, task: task)) {
                let responce: SystemConfiguration = (responce?.getCurrent())!
                Settings.showUponRegistrationMale = responce.showMale
                Settings.showUponRegistrationFemale = responce.showFemale
                
                if Settings.isLogined {
                    parameters["locale"] = Settings.currentLocale
                    self.requestTool.request(route: configTask.route, parameters: parameters, useToken: true, parcer: { (data) -> Response? in
                        do {
                            let result: Technical = try JSONDecoder().decode(Technical.self, from: data)
                            return result
                        } catch let error {
                            self.errorTool.postError(task: task,
                                                    result: SystemResult(status: .undifferentError),
                                                    messsage: error.localizedDescription,
                                                    status: .failed)
                            return nil
                        }
                    }) { (responce) in
                        self.close(task: task, with: SystemResult(status: .succses), task: .done)
                    }
                } else {
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                }
            }
        }
    }
    
    func getConfig(task: TrakerTask) {
        
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    private func deleteCache(task: TrakerTask) {
        cacheTool.removeCache()
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    
    private func set(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parameters,
                            useToken: true,
                            parcer: technicalParcer)
        { [weak self] (result) in
            if (self?.errorTool.validate(responce: result, task: task))! {
                self?.close(task: task, with: SystemResult(status: .succses), task: .done)
            }
        }
        
    }
    
    private func configure(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parameters,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: SystemConfiguration = try JSONDecoder().decode(SystemConfiguration.self, from: data)
                                    return response
                                } catch let error {
                                    _ = self.errorTool.validate(responce: nil, task: task)
                                    self.errorTool.postError(task: task,
                                                             result: SystemResult(status: .undifferentError),
                                                             messsage: error.localizedDescription,
                                                             status: .failed)
                                    return nil
                                }
        }) { [weak self] (result) in
            if (self?.errorTool.validate(responce: result, task: task))! {
                let config: SystemConfiguration = result as! SystemConfiguration
                self?.close(task: task,
                            with: ConfigResult(config: config,
                                               status: .succses),
                            task: .done)
            }
        }
    }
    
    private func hasToken(task: TrakerTask) -> SystemLogined {
        
        var trakerTask: TrakerTask = task
        trakerTask.status = .done
        
        if cacheTool.getToken() != "" {
            manager.traker.close(trakerTask: trakerTask)
            return SystemLogined(hasToken: true, operationStatus: .succses)
        }
        
        manager.traker.close(trakerTask: trakerTask)
        return SystemLogined(hasToken: false, operationStatus: .succses)
        
    }
}
