//
//  ChatsService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 20/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import Starscream

final class ChatsService {
    enum Event {
        case changedChat(AKChat)
        case removedChat(AKChat)
        case createdChat(AKChat)
    }
    
    private lazy var socket: WebSocket = {
        let url = URL(string: GlobalDefinitions.ChatService.wsDomain + "/ws/rooms?token=\(SessionService.userToken)&app_key=\(GlobalDefinitions.ChatService.appKey)")!
        let request = URLRequest(url: url)
        return WebSocket(request: request)
    }()
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    lazy var event: Observable<Event> = {
        Observable<Event>.create { [weak self] observer in
            self?.socket.onEvent = { event in
                switch event {
                case .text(let string):
                    guard let response = ChatTransformation.from(chatsWebSocket: string) else {
                        return
                    }
                    
                    observer.onNext(response)
                default:
                    break
                }
            }
            
            return Disposables.create()
        }
    }().share(replay: 1, scope: .forever)
}

extension ChatsService {
    static func getChats() -> Single<[AKChat]> {
        let request = GetChatsRequest(userToken: SessionService.userToken)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { ChatTransformation.from(response: $0) }
    }
}
