//
//  DatingCities.swift
//  DatingKit
//
//  Created by Alexey Prazhenik on 2/13/20.
//

import Foundation


open class Cities {
    
    private var manager: Manager
    
    init(manager: Manager) {
        self.manager = manager
    }
    
    public typealias SearchCityCompletion = (_ cities: [CityItem]?, _ operationStatus: ResultStatus) -> Void
    public func startSearchCity(city: String, completion: @escaping SearchCityCompletion) {
        
        let task = SearchCityTask(city: city)
        manager.takeToWork(task: task) { (result) in
            let searchResult = result as! CitiesResult
            completion(searchResult.cities, searchResult.status)
        }
    }
    
    public typealias AddCityCompletion = (_ cityID: Int?, _ operationStatus: ResultStatus) -> Void
    public func addCity(city: String, completion: @escaping AddCityCompletion) {
        
        let task = AddCityTask(city: city)
        manager.takeToWork(task: task) { (result) in
            let result = result as! CityAddResult
            completion(result.cityID, result.status)
        }
    }
    
    public func stopAll() {
        let task = StopAllCitiesTask()
        manager.takeToWork(task: task) { (result) in
            
        }
    }
    
}
