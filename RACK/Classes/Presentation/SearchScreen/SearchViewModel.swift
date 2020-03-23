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
    let like = PublishRelay<ProposedInterlocutor>()
    private(set) lazy var likeWasPut = createLikeComplete()
    
    let dislike = PublishRelay<ProposedInterlocutor>()
    private(set) lazy var dislikeWasPut = createDislikeComplete()
    
    let downloadProposedInterlocutors = PublishRelay<Void>()
    private(set) lazy var proposedInterlocutors = createProposedInterlocutors()
    
    private(set) lazy var needPayment = _needPayment.asSignal()
    private let _needPayment = PublishRelay<Void>()
    
    private func createProposedInterlocutors() -> Driver<[ProposedInterlocutor]> {
        downloadProposedInterlocutors
            .flatMapLatest {
                SearchService
                    .proposedInterlocuters()
                    .do(onError: { [weak self] error in
                        if let paymentError = error as? PaymentError, paymentError == .needPaymentError {
                            self?._needPayment.accept(Void())
                        }
                    })
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    private func createLikeComplete() -> Signal<ProposedInterlocutor> {
        like
            .flatMap { prposedInterlocutor in
                SearchService
                    .likeProposedInterlocutor(with: prposedInterlocutor.id)
                    .map { prposedInterlocutor }
                    .catchError { _ in .never() }
                }
            .asSignal(onErrorSignalWith: .never())
    }
    
    private func createDislikeComplete() -> Signal<ProposedInterlocutor> {
        dislike
            .flatMap { prposedInterlocutor in
                SearchService
                    .dislikeProposedInterlocutor(with: prposedInterlocutor.id)
                    .map { prposedInterlocutor }
                    .catchError { _ in .never() }
                }
            .asSignal(onErrorSignalWith: .never())
    }
}
