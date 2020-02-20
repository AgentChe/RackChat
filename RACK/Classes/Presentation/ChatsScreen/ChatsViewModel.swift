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
    lazy var chats = createChats()
    
    private func createChats() -> Driver<[AKChat]> {
        return ChatsService
            .getChats()
            .asDriver(onErrorJustReturn: [])
    }
}
