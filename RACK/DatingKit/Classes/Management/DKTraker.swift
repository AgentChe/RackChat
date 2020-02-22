//
//  Traker.swift
//  DatingKit
//
//  Created by Алексей Петров on 24/09/2019.
//

import Foundation

class DKTrakerTask: TrakerTask {
    
    var performer: Worker
    
    var id: UUID
    
    var status: TaskStatus
    
    var userTask: Task
    
    var handler: (Result) -> Void
    
    init(task: Task, performer: Worker, handler: @escaping (Result) -> Void) {
        self.handler = handler
        userTask = task
        status = .none
        id = UUID()
        self.performer = performer
    }
    
}

class DKTraker: Traker {

    var treatmentTasks: [TrakerTask]
    var failedTasks: [TrakerTask]
    private var repeadedTask: [TrakerTask]
    
    init() {
        treatmentTasks = []
        failedTasks = []
        repeadedTask = []
    }
    
    func removeAutorepeadedTask(trakerTask: TrakerTask) {
        if let index = repeadedTask.index(where: {$0.id == trakerTask.id}) {
            repeadedTask.remove(at: index)
            
        }
    }
    
    func setAutoReopenedTask(trakerTask: TrakerTask) {
        if repeadedTask.contains(where: { (task) -> Bool in
            return task.id == trakerTask.id
        }) == false {
            repeadedTask.append(trakerTask)
        }
    }
    
    func reopenTasks() {
        if repeadedTask.count > 0 {
            repeadedTask.forEach { (repeadedTask) in
                var task: TrakerTask = repeadedTask
                task.status = TaskStatus.waiting
                treatmentTasks.append(task)
                task.performer.perfom(task: task)
                
            }
        }
    }
    
    func getStatus(for task: Task) -> TaskStatus {
        return .waiting
    }
    
    func updateStatusFor(traker: TrakerTask) {
        update(task: traker)
    }
    
    
    func close(trakerTask: TrakerTask) {
        switch trakerTask.status {
        case .failed:
            remove(task: trakerTask)
        case .done:
            remove(task: trakerTask)
        case .failedFromInternetConnection:
            remove(task: trakerTask)
            failedTasks.append(trakerTask)
        default :
            break
        }
    }
    
    func set(trakerTask: TrakerTask, for worker: Worker) {
        var task: TrakerTask = trakerTask
        task.status = TaskStatus.waiting
        treatmentTasks.append(task)
        worker.perfom(task: trakerTask)
    }
    
    private func update(task: TrakerTask) {
        if let index = treatmentTasks.index(where: {$0.id == task.id}) {
            treatmentTasks[index].status = task.status
        }
    }
    
    private func remove(task: TrakerTask) {
        if let index = treatmentTasks.index(where: {$0.id == task.id}) {
            treatmentTasks.remove(at: index)

        }
    }
    
    func set(task: Task, for worker: Worker, completion: @escaping (Result) -> Void) {
        
    }
    
    func repeadFailedTasks() {
        if failedTasks.count > 0 {
            failedTasks.forEach { (failedTask) in
                if failedTask.userTask.autoRepeat {
                    var task: TrakerTask = failedTask
                    task.status = TaskStatus.waiting
                    treatmentTasks.append(task)
                    task.performer.perfom(task: task)
                }
                
            }
            failedTasks.removeAll()
        }
    }
    
}
