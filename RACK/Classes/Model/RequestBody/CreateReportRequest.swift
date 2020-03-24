//
//  CreateReportRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 01/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct CreateReportOnChatInterlocutorRequest: APIRequestBody {
    private let userToken: String
    private let chatId: String
    private let report: ReportViewController.Report
    
    init(userToken: String, chatId: String, report: ReportViewController.Report) {
        self.userToken = userToken
        self.chatId = chatId
        self.report = report
    }
    
    var url: String {
        GlobalDefinitions.ChatService.restDomain + "/api/v1/rooms/report"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "app_key": GlobalDefinitions.ChatService.appKey,
            "token": userToken,
            "room": chatId,
            "report": [
                "type": report.type.rawValue,
                "wording": report.message ?? "null"
            ]
        ]
    }
}

struct CreateReportOnProposedInterlocutorRequest: APIRequestBody {
    private let userToken: String
    private let proposedInterlocutorId: Int
    private let report: ReportViewController.Report
    
    init(userToken: String, proposedInterlocutorId: Int, report: ReportViewController.Report) {
        self.userToken = userToken
        self.proposedInterlocutorId = proposedInterlocutorId
        self.report = report
    }
    
    var url: String {
        GlobalDefinitions.Backend.domain + "/api/feed/report"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params: [String: Any] = [
            "_api_key": GlobalDefinitions.Backend.apiKey,
            "_user_token": userToken,
            "target_user_id": proposedInterlocutorId,
            "reason": report.type.rawValue
        ]
        
        if report.type == .other, let reportMessage = report.message {
            params["custom"] = reportMessage
        }
        
        return params
    }
}
