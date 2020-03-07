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
    
    func register() {
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
    
    var user: Driver<UserShow?> {
        Single<UserShow?>.create { event in
            DatingKit.user.show { user, status in
                if status == .succses {
                    event(.success(user))
                } else {
                    event(.success(nil))
                }
            }
            
            return Disposables.create()
        }
        .asDriver(onErrorJustReturn: nil)
    }
}
