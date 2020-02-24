//
//  PaginationDataLoader.swift
//  RACK
//
//  Created by Andrey Chernyshev on 24/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

struct Page<T> {
    let offset: Int
    let limit: Int
    let data: [T]

    var nextOffset: Int? {
        return data.isEmpty ? nil : offset + limit
    }
}

final class PaginatedDataLoader<E> {
    let loading: Driver<Bool>
    let error: Driver<Error>
    let elements: Driver<[E]>

    private let disposeBag = DisposeBag()

    init(firstTrigger: Observable<Void>, nextTrigger: Observable<Void>, observableFactory: @escaping (Int) -> Observable<Page<E>>) {
        let activityIndicator = RxActivityIndicator()
        loading = activityIndicator.asDriver()
        
        let errorRelay = PublishRelay<Error>()
        error = errorRelay.asDriver(onErrorDriveWith: .never())
        
        func load(_ nextOffset: Int) -> Observable<Page<E>> {
            return observableFactory(nextOffset)
                .trackActivity(activityIndicator)
                .catchError { error in
                    errorRelay.accept(error)
                    return .empty()
                }
        }
        
        let lastPage = PublishSubject<Page<E>>()
        
        let firstPage = firstTrigger.flatMapLatest { load(0) }
        
        let nextPage = firstTrigger.flatMapLatest {
            nextTrigger.withLatestFrom(lastPage)
                .flatMapFirst { $0.nextOffset.map { load($0) } ?? .empty() }
        }
        
        Observable.merge(firstPage, nextPage)
            .subscribe(lastPage)
            .disposed(by: disposeBag)
        
        elements = firstTrigger
            .flatMapLatest {
                lastPage.map { $0.data }
                    .scan([]) { $0 + $1 }
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
