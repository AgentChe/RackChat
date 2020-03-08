//
//  ChatService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 24/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import Starscream

final class ChatService {
    enum Action {
        case sendText(text: String)
        case sendImage(imagePath: String)
        case markRead(messageId: String)
    }
    
    enum Event {
        case newMessage(AKMessage)
        case removedChat
    }
    
    private let chat: AKChat
    
    private lazy var socket: WebSocket = {
        let url = URL(string: GlobalDefinitions.ChatService.wsDomain + "/ws/room/\(chat.id)?token=\(SessionService.userToken)&app_key=\(GlobalDefinitions.ChatService.appKey)")!
        let request = URLRequest(url: url)
        return WebSocket(request: request)
    }()
    
    init(chat: AKChat) {
        self.chat = chat
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func send(action: Action) {
        switch action {
        case .sendText(let text):
            send(text: text)
        case .sendImage(let imagePath):
            send(imagePath: imagePath)
        case .markRead(let messageId):
            markRead(messageId: messageId)
        }
    }
    
    lazy var event: Observable<Event> = {
        Observable<Event>.create { [weak self] observer in
            self?.socket.onEvent = { event in
                switch event {
                case .text(let string):
                    guard let response = ChatTransformation.from(chatWebSocket: string) else {
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

extension ChatService {
    fileprivate func send(text: String) {
        guard let json = [
            "action": "send",
            "type": 0,
            "value": text
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
    
    fileprivate func send(imagePath: String) {
        guard let json = [
            "action": "send",
            "type": 1,
            "value": imagePath
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
    
    fileprivate func markRead(messageId: String) {
        guard let json = [
            "action": "read",
            "value": messageId
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
}

extension ChatService {
    static func getMessages(chatId: String, page: Int) -> Single<[AKMessage]> {
        let request = GetMessagesRequest(userToken: SessionService.userToken,
                                         chatId: chatId,
                                         page: page)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { MessageTransformation.from(response: $0) }
    }
}
