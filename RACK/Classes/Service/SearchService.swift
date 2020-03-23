//
//  MatchService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import Starscream

final class SearchService {
    static func proposedInterlocuters() -> Single<[ProposedInterlocutor]> {
        let request = GetProposedInterlocutorsRequest(userToken: SessionService.userToken)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { ProposedInterlocutorTransformation.from(response: $0) }
    }
    
    static func likeProposedInterlocutor(with id: Int) -> Single<Void> {
        let request = LikeProposedInterlocutorRequest(userToken: SessionService.userToken, proposedInterlocutorId: id)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { try CheckResponseForError.throwIfError(response: $0) }
    }
    
    static func dislikeProposedInterlocutor(with id: Int) -> Single<Void> {
        let request = DislikeProposedInterlocutorRequest(userToken: SessionService.userToken, proposedInterlocutorId: id)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { try CheckResponseForError.throwIfError(response: $0) }
    }
    
    static func unmatch(chatId: String) -> Single<Void> {
        let request = UnmatchRequest(userToken: SessionService.userToken, chatId: chatId)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
    
    static func createReport(chatId: String, report: ReportViewController.Report) -> Single<Void> {
        let request = CreateReportRequest(userToken: SessionService.userToken, chatId: chatId, report: report)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
}
