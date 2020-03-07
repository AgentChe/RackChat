//
//  SearchViewModel.swift
//  RACK
//
//  Created by Andrey Chernyshev on 07/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

final class SearchViewModel {
    private let matchService = MatchService()
    
    func connect() {
        matchService.connect()
    }
    
    func disconnect() {
        matchService.disconnect()
    }
    
    func registered() {
        matchService.send(action: .register)
    }
    
    func skip() {
        matchService.send(action: .skip)
    }
    
    func sure() {
        matchService.send(action: .sure)
    }
    
    func close() {
        matchService.send(action: .close)
    }
    
    var event: Driver<MatchService.Event> {
        matchService
            .event
            .asDriver(onErrorDriveWith: .never())
    }
}
