//
//  Marketing.swift
//  Alamofire
//
//  Created by Алексей Петров on 16.12.2019.
//

import Foundation
import iAd
import AdSupport

class MarketingWorker: Worker {
    
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
    
    var currentTaskStatus: TaskStatus = .none
    
    init(manager: Manager, cache: CacheTool, error: ErrorTool, request: RequestTool) {
        self.cacheTool = cache
        self.requestTool = request
        self.errorTool = error
        self.manager = manager
    }
    
    func canProcess() -> Bool {
        return true
    }
    
    func perfom(task: TrakerTask) {
        let systemTaskType: MarketingTaskTypes = MarketingTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        
        switch systemTaskType {
        case .confirmAdAtributes:
            confirmADAtributes(task: task)
        case .setAdAtributes:
            setADAtributes(task: task)
        case .adColdStart:
            coldStart(task: task)
        }
        
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    private func coldStart(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: MarketingResult(status: .noInternetConnection, ads: nil),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        requestTool.request(route: "/users/set",
                            parameters: task.userTask.parameters,
                            useToken: true,
                            parcer: technicalParcer)
        { (responce) in
            if responce == nil {
                self.close(task: task, with: SystemResult(status: .undifferentError), task: .failed)
                return
            }
            if responce?.httpCode == 200 {
                self.close(task: task, with: SystemResult(status: .succses), task: .done)
            } else {
                self.close(task: task, with: SystemResult(status: .undifferentError), task: .failed)
            }
            
        }
    }
    
    private func setADAtributes(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: MarketingResult(status: .noInternetConnection, ads: nil),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        let launchedBefore = UserDefaults.standard.bool(forKey: Settings.AppIdentifiers.launchedBefore.rawValue)
        if launchedBefore == false  {
                
            UserDefaults.standard.set(true, forKey: Settings.AppIdentifiers.launchedBefore.rawValue)
            ADClient.shared().requestAttributionDetails { (adsParams, error) in
                if error != nil {
                    debugPrint(error?.localizedDescription)
                    self.errorTool.postError(task: task,
                                        result: SystemResult(status: .undifferentError),
                                        messsage: error!.localizedDescription,
                                        status: .failedFromInternetConnection)
                    return
                }
                
               if adsParams == nil {
                   self.close(task: task, with: SystemResult(status: .succses), task: .done)
                   return
               }
               
               guard let NSAdsParams: [String : NSObject] = adsParams else {
                   self.close(task: task, with: SystemResult(status: .succses), task: .done)
                   return
               }
               
               guard let NSAds: [String : NSObject] = NSAdsParams["Version3.1"] as! [String : NSObject] else {
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                    return
                }
                let ads: [String : Any] = NSAds
                
                let parameters: [String : Any] = task.userTask.parameters
                
                let fullParameters: [String : Any] = parameters.merging(ads) { $1 }
                
                self.requestTool.request(route: "/app_installs/register",
                                         parameters: fullParameters,
                                         useToken: false,
                                         parcer: self.technicalParcer)
                { (responce) in
                    self.close(task: task, with: MarketingResult(status: .succses, ads: ads), task: .done)
                }
                    
            }
        } else {
            self.close(task: task, with: MarketingResult(status: .succses, ads: nil), task: .done)
        }
    }
    
    private func confirmADAtributes(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            errorTool.postError(task: task,
                                result: SystemResult(status: .noInternetConnection),
                                messsage: "No internet Connection",
                                status: .failedFromInternetConnection)
            return
        }
        
        var parameters: [String : Any] = task.userTask.parameters
        
        parameters["locale"] = Settings.currentLocale
        parameters["timezone"] = Settings.localTimeZoneAbbreviation
        
        requestTool.request(route: "/users/set", parameters: parameters, useToken: true, parcer: technicalParcer) { (responce) in
            ADClient.shared().requestAttributionDetails { (adsParams, error) in
                if error != nil {
                    debugPrint(error?.localizedDescription)
                    self.errorTool.postError(task: task,
                                             result: MarketingResult(status: .undifferentError, ads: nil),
                                             messsage: error!.localizedDescription,
                                             status: .failedFromInternetConnection)
                    return
                }
                
                if adsParams == nil {
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                    return
                }
                
                guard let NSAdsParams: [String : NSObject] = adsParams as! [String : NSObject] else {
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                    return
                }

                
                guard let NSAds: [String : NSObject] = NSAdsParams["Version3.1"] as! [String : NSObject] else {
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                    return
                }
                let ads: [String : Any] = NSAds
                self.requestTool.request(route: "/users/add_search_ads_info", parameters: ads, useToken: true, parcer: self.technicalParcer) { (responce) in
                    self.close(task: task, with: SystemResult(status: .succses), task: .done)
                }
            }
        }
    }
    
}

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()

        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }

        return swiftDictionary
    }
}
