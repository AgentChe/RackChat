//
//  ReportViewModel.swift
//  RACK
//
//  Created by Andrey Chernyshev on 01/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

final class ReportViewModel {
    let loading = RxActivityIndicator()
    
    func createOnChatInterlocutor(report: ReportViewController.Report, chatId: String, proposedInterlocutorId: Int) -> Driver<Void> {
        SearchService
            .createReportOnChatInterlocutor(chatId: chatId, report: report)
            .flatMap { SearchService.createReportOnProposedInterlocutor(proposedInterlocutorId: proposedInterlocutorId, report: report) }
            .trackActivity(loading)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func createOnProposedInterlocutor(report: ReportViewController.Report, proposedInterlocutorId: Int) -> Driver<Void> {
        SearchService
            .createReportOnProposedInterlocutor(proposedInterlocutorId: proposedInterlocutorId, report: report)
            .trackActivity(loading)
            .asDriver(onErrorDriveWith: .never())
    }
}
