//
//  ReportManager.swift
//  FAWN
//
//  Created by Алексей Петров on 12/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public enum ReportReasons: Int {
    case InappropriateMessages = 1
    case InappropriatePhotos
    case spam
    case other
}

open class ReportManager {
    
    public static let shared = ReportManager()
    
    public func report(in chat: Double, with reason:ReportReasons, with completion: @escaping(_ succses: Bool) -> Void) {
        RequestManager.shared.request(.chatsReport, params: ["chat_id" : chat,
                                                             "reason" : reason.rawValue,
                                                             "wording" : ""
                                                             ])
        { (data) in
            let tech: Technical = data as! Technical
            if tech.httpCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func report(in chat: Double, message: String, with completion: @escaping(_ succses: Bool) -> Void) {
        RequestManager.shared.request(.chatsReport, params: ["chat_id" : chat,
                                                             "reason" : ReportReasons.other.rawValue,
                                                             "wording" : message])
        { (data) in
            let tech: Technical = data as! Technical
            if tech.httpCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func unmatch(in chat: Double, with completion: @escaping(_ succses: Bool) -> Void) {
        RequestManager.shared.request(.chatsUnmatch, params: ["chat_id" : chat])
        { (data) in
            let tech: Technical = data as! Technical
            if tech.httpCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
}
