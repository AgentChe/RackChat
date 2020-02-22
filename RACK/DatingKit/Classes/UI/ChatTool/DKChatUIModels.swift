//
//  DKChatUIModels.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public struct UIMessage: Equatable {
    
    public enum SendingStates {
        case sending, sendet, error, none
    }
    
    public var message: Message
    public var sendingState: SendingStates = .none
    
    public var body: String {
        return message.body
    }
    
    public var type: MessageType {
        return message.type
    }
    
    public var cacheID: String {
        return message.caheID
    }
    
    public var senderID: Int {
        return message.senderID
    }
    
    public var chatID: Int {
        return message.matchID
    }
    
    public var image: UIImage! {
        return message.sendetImage
    }
    
    public var base64: String {
        return message.base64Image
    }
    
    public var messageID: Int {
        return message.messageID
    }
    
    public init(message: Message, state: SendingStates) {
        self.message = message
        sendingState = state
    }
    
    public static func ==(lhs: UIMessage, rhs: UIMessage) -> Bool {
        return lhs.messageID == rhs.messageID && lhs.chatID == rhs.chatID && lhs.body == rhs.body
    }
    
    
//    public init(text: String, state: )
}
