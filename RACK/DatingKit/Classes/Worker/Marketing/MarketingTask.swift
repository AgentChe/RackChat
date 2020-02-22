//
//  MarketingTask.swift
//  Alamofire
//
//  Created by Алексей Петров on 16.12.2019.
//

import Foundation
import iAd
import AdSupport

public enum MarketingTaskTypes: Int {
    case setAdAtributes
    case confirmAdAtributes
    case adColdStart
}

public class MarketingTask: Task {
    
    public var needParameters: Bool = false
    
    public var route: String = "/api/app_installs/register"
    
    public var service: String = Servises.marketing.stringValue
    
    public var autoRepeat: Bool = true
    
    public var parametrs: [String : Any] = [String : Any]()
    
    public var status: TaskStatus = .none
    
    
    public var type: Int {
        return userType.rawValue
    }
       
    private var userType: MarketingTaskTypes
    
    init(type: MarketingTaskTypes) {
        userType = type
        parametrs["version"] = Int(Settings.currentBundle)
        parametrs["random_string"] = Settings.getCurrentInstallIdentifier()
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let idfa: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            parametrs["idfa"] = idfa
        
        }
       
        
    }
    
    init(storyCountry: String) {
        userType = .adColdStart
        parametrs["version"] = Int(Settings.currentBundle)
        parametrs["locale"] = Settings.currentLocale
        parametrs["timezone"] = Settings.localTimeZoneAbbreviation
        parametrs["store_country"] = storyCountry
    }
    
    init(type: MarketingTaskTypes, storeCountry: String) {
        userType = type
        parametrs["random_string"] = Settings.getCurrentInstallIdentifier()
        parametrs["version"] = Int(Settings.currentBundle)
        parametrs["store_country"] = storeCountry
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let idfa: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            parametrs["idfa"] = idfa
        }
    }
    
}

public class MarketingResult: Result {
    
    public var status: ResultStatus
    public var ads: [String: Any]?
    
    init(status: ResultStatus, ads: [String: Any]?) {
        self.status = status
        self.ads = ads
    }
    
}
