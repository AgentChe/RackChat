//
//  ErrorTool.swift
//  DatingKit
//
//  Created by Алексей Петров on 30/09/2019.
//

import Foundation


open class ErrorTool {
    
    private var traker: Traker
    
    init(traker: Traker) {
        self.traker = traker
    }
    
    public func validate(responce: Response?, task: TrakerTask, result: Result) -> Bool {
        if responce == nil {
            postError(task: task, result: result, messsage: "Responce is nil", status: .failed)
            return false
        }
        
        if responce!.needPayment {
            postError(task: task, result: result, messsage: "need payment", status: .failed)
            return false
        }
        
        if responce!.httpCode != 200 {
            let message: String = "\(responce!.message) HTTP Code: \(responce!.httpCode)"
            postError(task: task, result: result, messsage: message, status: .failed)
            return false
        } else {
            return true
        }
    }
    
    public func validate(responce: Response?, task: TrakerTask) -> Bool {
        if responce == nil {
            postError(task: task, result: SystemResult(status: .undifferentError), messsage: "Responce is nil", status: .failed)
            return false
        }
        
        if responce!.httpCode != 200 {
            let message: String = "\(responce!.message) HTTP Code: \(responce!.httpCode)"
            postError(task: task, result: SystemResult(status: .undifferentError), messsage: message, status: .failed)
            return false
        } else  {
            return true
        }
    }
    
    
    
    public func postError(message: String, process: String) {
        debugPrint("==============================")
        debugPrint("ERROR: ", message)
        debugPrint("process: ", process)
        debugPrint("==============================")
    }
    
    public func postError(task: TrakerTask, result: Result, messsage: String, status: TaskStatus) {
        debugPrint("==============================")
        debugPrint("ERROR: ", messsage)
        debugPrint("Task: ", task.id)
        debugPrint("route: ", task.userTask.route)
        debugPrint("==============================")
        close(task: task, with: result, task: status)
        
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
}
