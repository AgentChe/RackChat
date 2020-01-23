//
//  SearchTask.swift
//  DatingKit
//
//  Created by Алексей Петров on 18.10.2019.
//

import Foundation

public enum Actions: Int {
    case WaitUser = 1
    case WaitCompanion
}

public enum MatchStatus: Int {
    case waitPartnerAnser = 1
    case timeOut
    case deny
    case confirmPending
    case lostChat
    case report
    case cantAnswer
}

public enum SearchTaskTypes: Int {
    case search
    case sayYes
    case sayNo
    case stopSearch
    case stopAll
}

open class StopAllTask: Task {
    
    public var needParameters: Bool
    
    public var route: String
    
    public var service: String
    
    public var autoRepeat: Bool
    
    public var parametrs: [String : Any]
    
    public var status: TaskStatus
    
    public var type: Int {
        return searchType.rawValue
    }
    
    private var searchType: SearchTaskTypes
    
    init() {
        needParameters = false
        route = ""
        service = Servises.search.stringValue
        autoRepeat = false
        parametrs = [String : Any]()
        status = .none
        searchType = .stopAll
    }
    
    
}

open class SearchTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    
    public var type: Int {
        return searchType.rawValue
    }
    
    private var searchType: SearchTaskTypes
    
    init(email: String) {
        needParameters = true
        route = "/requests/search"
        service = Servises.search.stringValue
        autoRepeat = true
        parametrs = ["email" : email]
        status = .none
        searchType = .search
    }
}

open class StopSearchTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return searchType.rawValue
    }
    
    private var searchType: SearchTaskTypes
    
    init() {
        needParameters = false
        route = ""
        service = Servises.search.stringValue
        autoRepeat = false
        parametrs = [String : Any]()
        status = .none
        searchType = .stopSearch
    }
    
}

open class SayNoTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return searchType.rawValue
    }
    
    private var searchType: SearchTaskTypes
    
    init(matchID: Int) {
        needParameters = true
        route = "/requests/say_no"
        service = Servises.search.stringValue
        autoRepeat = false
        parametrs = ["match_id" : matchID]
        status = .none
        searchType = .sayNo
    }
}

open class SayYesTask: Task {
    
    public var needParameters: Bool
    public var route: String
    public var service: String
    public var autoRepeat: Bool
    public var parametrs: [String : Any]
    public var status: TaskStatus
    public var type: Int {
        return searchType.rawValue
    }
    
    private var searchType: SearchTaskTypes
    
    init(matchID: Int) {
        needParameters = true
        route = "/requests/say_yes"
        service = Servises.search.stringValue
        autoRepeat = true
        parametrs = ["match_id" : matchID]
        status = .none
        searchType = .sayYes
    }
    
}
