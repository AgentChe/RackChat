//
//  ChatViewModel.swift
//  RACK
//
//  Created by Andrey Chernyshev on 21/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import RxCocoa

final class ChatViewModel {
    let nextPage = PublishRelay<Void>()
    
    private(set) lazy var paginatedLoader = createLoader()
    
    private let chat: AKChat
    let chatService: ChatService
    
    init(chat: AKChat) {
        self.chat = chat
        chatService = ChatService(chat: chat)
    }
    
    func connect() {
        chatService.connect()
    }
    
    func disconnect() {
        chatService.disconnect()
    }
    
    var newMessages: Driver<[AKMessage]> {
        return Driver
            .merge(paginatedLoader.elements,
                   receiveNewMessages().map { [$0] }.asDriver(onErrorJustReturn: []))
    }
    
    private func createLoader() -> PaginatedDataLoader<AKMessage> {
        let chatId = chat.id
        
        return PaginatedDataLoader(firstTrigger: .just(Void()), nextTrigger: nextPage.asObservable()) { page in
            ChatService
                .getMessages(chatId: chatId, page: page)
                .map { Page(page: page, data: $0) }
                .asObservable()
        }
    }
    
    private func receiveNewMessages() -> Observable<AKMessage> {
        return chatService
            .event
            .flatMap { event -> Observable<AKMessage> in
                return Observable.create { observer in
                    switch event {
                    case .newMessage(let message):
                        observer.onNext(message)
                    }
                    
                    return Disposables.create()
                }
            }
    }
}
