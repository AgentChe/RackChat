//
//  Settings.swift
//  Alamofire
//
//  Created by Алексей Петров on 05.11.2019.
//

import Foundation

open class Settings {
    
    public enum AppIdentifiers: String, CodingKey {
        public typealias RawValue = String
        case installAppIDenitfier
        case launchedBefore
    }
            
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
    
    public static var currentBundle: String = ""
    public static var currentLocale: String = ""
    public static var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
    static var storeCountry: String = ""
    public static var showUponRegistrationMale: Bool = false
    public static var showUponRegistrationFemale: Bool = false
    
    static var isLogined: Bool {
        return CacheTool.shared.getToken() != ""
    }
    
    public static var auto: Bool = true
    
    public class func set(times: Timings, autoSettings: Bool, bundle: String) {
        timings = times
        auto = autoSettings
    }
    
    class func getCurrentInstallIdentifier() -> String {
        if let identifier: String = (UserDefaults.standard.object(forKey: AppIdentifiers.installAppIDenitfier.stringValue) as? String)  {
            return identifier
        }
        
        let identifier: String = UUID().uuidString
        UserDefaults.standard.set(identifier, forKey: AppIdentifiers.installAppIDenitfier.stringValue)
        return identifier
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
