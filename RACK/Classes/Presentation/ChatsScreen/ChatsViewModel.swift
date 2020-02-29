//
//  ChatsViewModel.swift
//  RACK
//
//  Created by Andrey Chernyshev on 20/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

final class ChatsViewModel {
    private let chatsService = ChatsService()
    
    func connect() {
        chatsService.connect()
    }
    
    var newChats: Driver<[AKChat]> {
        return ChatsService
            .getChats()
            .asDriver(onErrorJustReturn: [])
    }
    
    func changedChat() -> Driver<AKChat> {
        return chatsService
            .event
            .flatMap { event -> Observable<AKChat> in
                switch event {
                case .changedChat(let chat):
                    return .just(chat)
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
