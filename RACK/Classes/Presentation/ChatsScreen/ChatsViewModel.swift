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
    let checkPayment = PublishRelay<Void>()
    private(set) lazy var checkPaymentComplete = checkPaymentAction()
    
    private let chatsService = ChatsService()
    
    func connect() {
        chatsService.connect()
    }
    
    var newChats: Driver<[Chat]> {
        return ChatsService
            .getChats()
            .asDriver(onErrorJustReturn: [])
    }
    
    func chatEvent() -> Driver<ChatsService.Event> {
        return chatsService
            .event
            .asDriver(onErrorDriveWith: .never())
    }
    
    private func checkPaymentAction() -> Driver<Bool> {
        checkPayment
            .throttle(RxTimeInterval.microseconds(400), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest { PaymentService.checkNeedPayment() }
            .asDriver(onErrorDriveWith: .never())
    }
}
