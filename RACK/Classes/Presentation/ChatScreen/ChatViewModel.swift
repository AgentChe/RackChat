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
    private var chatService: ChatService?
    
    func connect(to chat: AKChat) {
        if chatService == nil {
            chatService = ChatService(chat: chat)
        }
        
        chatService?.connect()
    }
    
    func disconnect() {
        chatService?.disconnect()
    }
}
