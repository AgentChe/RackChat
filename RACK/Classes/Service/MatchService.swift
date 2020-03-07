//
//  MatchService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 22/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import RxSwift
import Starscream

final class MatchService {
    enum Action {
        case register
        case skip
        case sure
        case close
    }
    
    enum TechnicalEvent {
        case socketConnected
    }
    
    enum Event {
        case registered(SearchingQueueId)
        case matchProposed([MatchProposed])
        case refused([SearchingQueueId])
        case coupleFormed([SearchingQueueId])
        case technical(TechnicalEvent)
    }
    
    private lazy var socket: WebSocket = {
        let url = URL(string: GlobalDefinitions.ChatService.wsDomain + "/ws/match?app_key=\(GlobalDefinitions.ChatService.appKey)")!
        let request = URLRequest(url: url)
        return WebSocket(request: request)
    }()
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func send(action: Action) {
        switch action {
        case .register:
            register()
        case .skip:
            skip()
        case .sure:
            sure()
        case .close:
            close()
        }
    }
    
    var event: Observable<Event> {
        Observable<Event>.create { [socket] observer in
            socket.onEvent = { event in
                switch event {
                case .connected(_):
                    observer.onNext(.technical(.socketConnected))
                case .text(let string):
                    guard let response = MatchTransformation.from(matchWebSocket: string) else {
                        return
                    }
                    
                    observer.onNext(response)
                default:
                    break
                }
            }
            
            return Disposables.create()
        }
        .share(replay: 1, scope: .forever)
    }
}

extension MatchService {
    fileprivate func register() {
        guard let json = [
            "action": "register",
            "token": SessionService.userToken
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
    
    fileprivate func skip() {
        guard let json = [
            "action": "skip",
            "token": SessionService.userToken
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
    
    fileprivate func sure() {
        guard let json = [
            "action": "sure",
            "token": SessionService.userToken
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
    
    fileprivate func close() {
        guard let json = [
            "action": "close",
            "token": SessionService.userToken
        ].jsonString() else {
            return
        }
        
        socket.write(string: json)
    }
}

extension MatchService {
    static func unmatch(chatId: String) -> Single<Void> {
        let request = UnmatchRequest(userToken: SessionService.userToken, chatId: chatId)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
    
    static func createReport(chatId: String, report: ReportViewController.Report) -> Single<Void> {
        let request = CreateReportRequest(userToken: SessionService.userToken, chatId: chatId, report: report)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
}
