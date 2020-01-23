//
//  Settings.swift
//  Alamofire
//
//  Created by Алексей Петров on 05.11.2019.
//

import Foundation

open class Settings {
            
    static var chatsUpdatingTime: Double {
        return timings.chatsUpdatingTime
    }
    
    static var chatUpdatingTimer: Double {
        return timings.chatUpdatingTimer
    }
    
    static var searchTime: Double {
        return timings.searchTime
    }
    
    static var matchChekTime: Double {
        return timings.matchChekTime
    }
    
    static var searchStopTime: Double {
        return timings.searchStopTime
    }
    
    static var timings: Timings = Timings()
    
    static var auto: Bool = true
    static var currentBundle: String = ""
    static var storeCountry: String = ""
    static var showUponRegistrationMale: Bool = false
    static var showUponRegistrationFemale: Bool = false
    
    public static func set(times: Timings, autoSettings: Bool, bundle: String) {
        timings = times
        auto = autoSettings
        currentBundle = bundle
    }
    
    public struct Timings {
        var chatsUpdatingTime: Double
        var chatUpdatingTimer: Double
        var searchTime: Double
        var matchChekTime: Double
        var searchStopTime: Double
        
        public init() {
            chatsUpdatingTime = 2.5
            chatUpdatingTimer = 2.0
            searchTime = 3.0
            matchChekTime = 1.0
            searchStopTime = 100
        }
        
        public init(chatsUpdatingTime: Double,
             chatUpdatingTimer: Double,
             searchTime: Double,
             matchChekTime: Double,
             searchStopTime: Double) {
            
            self.chatsUpdatingTime = chatsUpdatingTime
            self.chatUpdatingTimer = chatUpdatingTimer
            self.searchTime = searchTime
            self.matchChekTime = matchChekTime
            self.searchStopTime = searchStopTime
            
        }
        
    }
    
}
