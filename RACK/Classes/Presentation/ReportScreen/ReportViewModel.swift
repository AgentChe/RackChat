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
    
    func create(report: ReportViewController.Report, chatId: String) -> Driver<Void> {
        MatchService
            .createReport(chatId: chatId, report: report)
            .trackActivity(loading)
            .asDriver(onErrorDriveWith: .never())
    }
}
