//
//  CitiesTask.swift
//  DatingKit
//
//  Created by Alexey Prazhenik on 2/13/20.
//

import Foundation

public enum CitiesTaskTypes: Int {
    case searchCity
    case addCity
    case stopAll
}

open class StopAllCitiesTask: Task {
    
    public var needParameters: Bool
    
    public var route: String
    
    public var service: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus
    
    public var type: Int {
        return taskType.rawValue
    }
    
    private var taskType: CitiesTaskTypes
    
    init() {
        needParameters = false
        route = ""
        service = Servises.cities.stringValue
        autoRepeat = false
        parametrs = [String : Any]()
        status = .none
        taskType = .stopAll
    }
    
}


open class SearchCityTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return taskType.rawValue
    }
    
    private var taskType: CitiesTaskTypes
    
    init(city: String) {
        needParameters = true
        route = "/cities/search"
        service = Servises.cities.stringValue
        autoRepeat = true
        parametrs = ["search" : city]
        status = .none
        taskType = .searchCity
    }
}


open class AddCityTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return taskType.rawValue
    }
    
    private var taskType: CitiesTaskTypes
    
    init(city: String) {
        needParameters = true
        route = "/cities/add"
        service = Servises.cities.stringValue
        autoRepeat = true
        parametrs = ["city" : city]
        status = .none
        taskType = .addCity
    }
}

