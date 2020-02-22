//
//  Protocols.swift
//  DatingKit
//
//  Created by Алексей Петров on 24/09/2019.
//

import Foundation

public enum TaskStatus: Int {
    
    case failedFromInternetConnection
    case waiting
    case valid
    case invalid
    case treatment
    case done
    case failed
    case none
    
}

public enum Gender: Int {
    case none = 0
    case man = 1
    case woman = 2
}

public enum ResultStatus: Int {
    case none
    case succses
    case noServicesInitialazed
    case noInternetConnection
    case forbitten
    case badGateway
    case needPayment
    case notLogined
    case undifferentError
    case banned
    case timeOut
}


public protocol Response: Decodable {
    var httpCode: Double { get }
    var message: String { get }
    var needPayment: Bool { get }
    
    func getCurrent<T: Response>() -> T
}

public extension Response {
    func getCurrent<T: Response>() -> T {
        return self as! T
    }
}

public protocol Owner {
    
    var manager: Manager { get }
    
}

public protocol Manager {
    
    var workers: [String : Worker] { get }
    var traker: Traker { get }
    var services: [String] { get }
    
    func takeToWork(task: Task, completion:@escaping(_ result: Result) -> Void)
    
}

public protocol Traker {
    
    var treatmentTasks: [TrakerTask] { get }
    var failedTasks: [TrakerTask] { get }
    
    func set(task: Task, for worker: Worker, completion: @escaping(_ result: Result) -> Void)
    func set(trakerTask: TrakerTask, for worker: Worker)
    func close(trakerTask: TrakerTask)
    func updateStatusFor(traker: TrakerTask)
    func getStatus(for task: Task) -> TaskStatus
    func repeadFailedTasks()
    func setAutoReopenedTask(trakerTask: TrakerTask)
    func reopenTasks()
    func removeAutorepeadedTask(trakerTask: TrakerTask)
}

public protocol TrakerTask {
    
    var id: UUID { get }
    var userTask: Task { get }
    var status: TaskStatus { get set }
    var handler: (_ result: Result) -> Void { get }
    var performer: Worker { get set }
    
}

public protocol Task {
    
    var needParameters: Bool { get }
    var route: String { get }
    var service: String { get }
    var autoRepeat: Bool { get }
    var parametrs: [String : Any] { get }
    var status: TaskStatus { get set }
    var type: Int { get }
    
    func getCurrent<T: Task>() -> T
    
}

extension Task {
    public func getCurrent<T: Task>() -> T {
        return self as! T
    }
    
}

public protocol Result {
    
    var status: ResultStatus { get }
    
}

public protocol Resource {}

public protocol Tool {
    
    func getDataFor(task: Task, completion: @escaping (_ data: Any)-> Void)
    
}

public protocol Worker {
    
    var currentTaskStatus: TaskStatus { get }
    
    func canProcess() -> Bool
    func perfom(task: TrakerTask)
    
}
