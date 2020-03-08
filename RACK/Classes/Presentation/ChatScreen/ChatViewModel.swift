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
    let viewedMessage = PublishRelay<AKMessage>()
    let sendText = PublishRelay<String>()
    let sendImage = PublishRelay<UIImage>()
    
    private lazy var paginatedLoader = createLoader()
    
    private let chat: AKChat
    private let chatService: ChatService
    
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
    
    func chatRemoved() -> Signal<Void> {
        return chatService.event
            .flatMap { [weak self] event -> Observable<Void> in
                switch event {
                case .removedChat(let chatId):
                    guard self?.chat.id == chatId else {
                        return .never()
                    }
                    
                    return .just(Void())
                default:
                    return .never()
                }
            }
            .asSignal(onErrorSignalWith: .never())
    }
    
    func sender() -> Observable<Never> {
        let text = sendText
            .concatMap { text in
                Completable.create { [weak self] event in
                    self?.chatService.send(action: .sendText(text: text))
                    
                    event(.completed)
                    
                    return Disposables.create()
                }
            }
        
        let image = sendImage
            .concatMap { FileService.send(image: $0) }
            .flatMap { imagePath in
                Completable.create { [weak self] event in
                    if let path = imagePath {
                        self?.chatService.send(action: .sendImage(imagePath: path))
                    }
                    
                    event(.completed)
                    
                    return Disposables.create()
                }
            }
        
        let viewed = viewedMessage
            .filter { !$0.isOwner }
            .debounce(RxTimeInterval.milliseconds(500), scheduler: SerialDispatchQueueScheduler.init(qos: .default))
            .flatMap { viewedMessage in
                Completable.create { [weak self] event in
                    self?.chatService.send(action: .markRead(messageId: viewedMessage.id))
                    
                    event(.completed)
                
                    return Disposables.create()
                }
            }
        
        return Observable<Never>.merge(text, image, viewed)
    }
    
    var newMessages: Driver<[AKMessage]> {
        Driver
            .merge(paginatedLoader.elements,
                   receiveNewMessages().map { [$0] }.asDriver(onErrorJustReturn: []))
    }
    
    private func createLoader() -> PaginatedDataLoader<AKMessage> {
        let chatId = chat.id
        
        let firstTrigger = Observable<Void>
            .deferred {
                .just(Void())
            }
        
        let nextTrigger = nextPage
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.asyncInstance)
        
        return PaginatedDataLoader(firstTrigger: firstTrigger,
                                   nextTrigger: nextTrigger) { page in
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
                switch event {
                case .newMessage(let message):
                    return .just(message)
                default:
                    return .never()
                }
            }
    }
}
