//
//  CitiesWorker.swift
//  DatingKit
//
//  Created by Alexey Prazhenik on 2/13/20.
//

import Foundation


class CitiesWorker: Worker {
    
    private var requestTool: RequestTool
    private var errorTool: ErrorTool
    private var manager: Manager
    private var searchTimer: Timer?
    private var checkTimer: Timer?
    private var stopSearchTimer: Timer?
    private var executedTask: TrakerTask?
    
    init(manager: Manager, errorTool: ErrorTool, requestTool: RequestTool) {
        self.manager = manager
        self.requestTool = requestTool
        self.errorTool = errorTool
    }
    
    func canProcess() -> Bool {
        return true
    }
    
    var currentTaskStatus: TaskStatus {
        return .treatment
    }
    
    func perfom(task: TrakerTask) {
        let taskType: CitiesTaskTypes = CitiesTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        
        switch taskType {
        case .searchCity:
            startSearch(task: task)

        case .stopAll:
            stopAll(task: task)

        case .addCity:
            addCity(task: task)
        }
        
    }
    
    private func stopAll(task: TrakerTask) {
        
        if searchTimer != nil {
            searchTimer?.invalidate()
        }
        
        if checkTimer != nil {
            checkTimer?.invalidate()
        }
        
        if stopSearchTimer != nil {
            stopSearchTimer!.invalidate()
        }
        
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    

    private func startSearch(task: TrakerTask) {
        
        executedTask = task
        
        stopSearchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchStopTime,
                                               repeats: false) { (timer) in
                                                self.close(task: task, with: SearchResult(match: DKMatch(), status: .timeOut), task: .done)
                                                debugPrint("==========================")
                                                debugPrint("search was endet by time")
                                                debugPrint("==========================")
                                                timer.invalidate()
                                                self.searchTimer?.invalidate()
        }
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchTime, repeats: true, block: { (timer) in
            
            if NetworkState.isConnected() == false {
                timer.invalidate()
                self.stopSearchTimer!.invalidate()
                
                self.errorTool.postError(task: task,
                                         result: SearchResult(match: DKMatch(), status: .noInternetConnection),
                                         messsage: "No Internet Connection",
                                         status: .failedFromInternetConnection)
                return
            }
            
            self.requestTool.request(route: task.userTask.route,
                                     parameters: task.userTask.parametrs,
                                     useToken: true,
                                     parcer:
                { (data) -> Response? in
                    do {
                        if task.userTask is SearchCityTask {
                            let response: CitiesResponse = try JSONDecoder().decode(CitiesResponse.self, from: data)
                            return response
                        } else {
                            let response: Match = try JSONDecoder().decode(Match.self, from: data)
                            return response
                        }
                    } catch let error {
                        if task.userTask is SearchCityTask {
                            // ??
                            self.errorTool.postError(message: error.localizedDescription, process: "")
                        } else {
                            self.errorTool.postError(task: task,
                                                     result: SearchResult(match: DKMatch(), status: .undifferentError),
                                                     messsage: error.localizedDescription,
                                                     status: .failed)
                        }
                        return nil
                    }
                    
            }) { [weak self] (data) in
                
                debugPrint("==========================")
                debugPrint("search state")
                debugPrint("==========================")
                
                if data == nil {
                    self!.stopSearchTimer!.invalidate()
                    timer.invalidate()
                    
                    if task.userTask is SearchCityTask {
                        
                    } else {
                        self?.errorTool.postError(task: task,
                                                  result: SearchResult(match: DKMatch(), status: .undifferentError),
                                                  messsage: "Responce is nil",
                                                  status: .failed)
                    }
                    
                    return
                }
                
                if data!.needPayment {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {
                        
                    } else {

                    }
                    return
                }
                
                if data?.httpCode == 400 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {

                    } else {

                    }
                    return
                }
                
                if data?.httpCode == 500 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {
                        
                    } else {
                    
                    }
                    return
                }
                
                if data?.httpCode == 200 {
                    
                    if task.userTask is SearchCityTask {
                        
                        let result: CitiesResponse = data as! CitiesResponse
                        if let _ = result.data {
                            
                            timer.invalidate()
                            self!.stopSearchTimer!.invalidate()
                            
                            debugPrint("==========================")
                            debugPrint("search stopped")
                            debugPrint("Found")
                            debugPrint("==========================")
                            
                            self?.close(task: task,
                                        with: CitiesResult(response: result, status: .succses),
                                        task: .done)
                            return
                            
                        }
                        else {
                            debugPrint("==========================")
                            debugPrint("no cities have been found!!")
                            debugPrint("==========================")
                        }
                    } else {
                        
                    }
                    
                } else {
                    self?.errorTool.postError(task: task,
                                              result: SearchResult(match: DKMatch(), status: .undifferentError),
                                              messsage: data!.message,
                                              status: .failed)
                }
            }
            
        })
        
    }
    
    
    private func addCity(task: TrakerTask) {
        
        executedTask = task
        
        stopSearchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchStopTime,
                                               repeats: false)
        { (timer) in
            self.close(task: task, with: CityAddResult(status: .timeOut), task: .done)
            debugPrint("==========================")
            debugPrint("search was endet by time")
            debugPrint("==========================")
            timer.invalidate()
            self.searchTimer?.invalidate()
        }
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchTime, repeats: true, block: { (timer) in
            
            if NetworkState.isConnected() == false {
                timer.invalidate()
                self.stopSearchTimer!.invalidate()
                
                self.errorTool.postError(task: task,
                                         result: CityAddResult(status: .noInternetConnection),
                                         messsage: "No Internet Connection",
                                         status: .failedFromInternetConnection)
                return
            }
            
            self.requestTool.request(route: task.userTask.route,
                                     parameters: task.userTask.parametrs,
                                     useToken: true,
                                     parcer:
            { (data) -> Response? in
                do {
                    let response: CityAddResponse = try JSONDecoder().decode(CityAddResponse.self, from: data)
                    return response
                } catch let error {
                    self.errorTool.postError(task: task,
                                             result: CityAddResult(status: .undifferentError),
                                             messsage: error.localizedDescription,
                                             status: .failed)
                    return nil
                }
                
            }) { [weak self] (data) in
                
                debugPrint("==========================")
                debugPrint("adding state")
                debugPrint("==========================")
                
                if data == nil {
                    self!.stopSearchTimer!.invalidate()
                    timer.invalidate()
                    
                    self?.errorTool.postError(task: task,
                                              result: CityAddResult(status: .undifferentError),
                                              messsage: "Responce is nil",
                                              status: .failed)

                    return
                }
                
                if data!.needPayment {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    return
                }
                
                if data?.httpCode == 400 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    return
                }
                
                if data?.httpCode == 500 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    return
                }
                
                if data?.httpCode == 200 {
                    
                    let result: CityAddResponse = data as! CityAddResponse
                    if let _ = result.cityID {
                        
                        timer.invalidate()
                        self!.stopSearchTimer!.invalidate()
                        
                        debugPrint("==========================")
                        debugPrint("adding stopped")
                        debugPrint("Found")
                        debugPrint("==========================")
                        
                        self?.close(task: task,
                                    with: CityAddResult(response: result, status: .succses),
                                    task: .done)
                        return
                        
                    }
                    else {
                        debugPrint("==========================")
                        debugPrint("no city have been added!!")
                        debugPrint("==========================")
                    }

                } else {
                    self?.errorTool.postError(task: task,
                                              result: CityAddResult(status: .undifferentError),
                                              messsage: data!.message,
                                              status: .failed)
                }
            }
            
        })
        
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    
    
}

