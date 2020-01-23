//
//  Manager.swift
//  DatingKit
//
//  Created by Алексей Петров on 24/09/2019.
//

import Foundation
import Reachability

public enum Servises: CodingKey {
    typealias RawValue = String
    case system
    case user
    case chats
    case currentChat
    case payment
    case search
    case notification
    
}

enum Tools: CodingKey {
    typealias RawValue = String
    case rechbility
    case requestManager
}

enum Resources: CodingKey {
    typealias RawValue = String
    case caheManager
}

class DKManager: Manager, NetworkStatusListener {
    
    var workers: [String : Worker]
    var traker: Traker
    var services: [String]
    
//    private let rechability: Reachability =
    private var baseURL: String
    private var apiKey: String
    private var requestTool: RequestTool
    private var cacheTool: CacheTool
    private var errorTool: ErrorTool
    
    init(services: [Servises]) {
        
        baseURL =  Bundle.main.object(forInfoDictionaryKey: "base_url") as! String
        apiKey = Bundle.main.object(forInfoDictionaryKey: "api_key") as! String
        cacheTool = CacheTool()
        requestTool = RequestTool(baseURL: baseURL, apiKey: apiKey, cache: cacheTool)
        traker =  DKTraker()
        errorTool = ErrorTool(traker: traker)
        workers = [:]
        self.services = []
        ReachabilityManager.shared.addListener(listener: self)
        services.forEach { (service) in
            self.services.append(service.stringValue)
            switch service {
            case .chats:
                workers[service.stringValue] = ChatWorker(manager: self,
                                                          requestTool: requestTool,
                                                          errorTool: errorTool,
                                                          cacheTool: cacheTool)
            case .user:
                workers[service.stringValue] = UserWorker(manager: self,
                                                          requestManager: requestTool,
                                                          cacheManager: cacheTool,
                                                          errorTool: errorTool)
            case .payment:
                break
            case .search:
                workers[service.stringValue] = SerachWorker(manager: self,
                                                            errorTool: errorTool,
                                                            requestTool: requestTool)
                break
            case .notification:
                break
            case .system:
                workers[service.stringValue] = SystemWorker(manager: self,
                                                            cache: cacheTool,
                                                            error: errorTool,
                                                            request: requestTool)
            case .currentChat:
                workers[service.stringValue] = CurrentChatWorker(manager: self,
                                                                 requestTool: requestTool,
                                                                 errorTool: errorTool,
                                                                 cacheTool: cacheTool)
            }
        }
        
    }
    

    
    func takeToWork(task: Task, completion: @escaping (Result) -> Void) {
        if services.count == 0 {
            print("ERROR: You not init a servises")
            completion(SystemResult(status: .noServicesInitialazed))
            return
        }
        
        if validateTask(task: task) == .invalid {
            completion(SystemResult(status: .undifferentError))
            return
        }
        
        if let worker = getWorkerFor(task: task) {
            let trakerTask: DKTrakerTask = DKTrakerTask(task: task, performer: worker, handler: completion)
            traker.set(trakerTask: trakerTask, for: worker)
        }
        
        
    }
    
    private func getWorkerFor(task: Task) -> Worker! {
        guard let worker = workers[task.service] else {
            print("ERROR: servise \(task.service) not exist")
            return nil
        }
        
        return worker
    }
    
    private func validateTask(task: Task) -> TaskStatus {
        if task.needParameters {
            if task.parametrs.count == 0 {
                print("ERROR: You enabled needParameters, but parametes count equels zero!")
                return .invalid
            }
        }
        
        if services.contains(task.service) == false {
            print("ERROR: servise \(task.service) not init")
            return .invalid
        }
        
        return .valid
    }
    
    func networkStatusDidChange(status: Reachability.Connection) {
        self.traker.repeadFailedTasks()
        self.traker.reopenTasks()
    }
}


class SystemResult: Result {
    
    var status: ResultStatus
    
    init(status: ResultStatus) {
        self.status = status
    }
}

