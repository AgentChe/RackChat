//
//  CreateReportRequest.swift
//  RACK
//
//  Created by Andrey Chernyshev on 01/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire

struct CreateReportRequest: APIRequestBody {
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
