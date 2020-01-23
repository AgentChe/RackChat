//
//  DKChatConfigurator.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public class DKChatConfigurator: ChatConfiguratorProtocol {
    
        
    public init() {
        
    }

    public func configurate(view: ChatViewProtocol) {
        let presenter: ChatPresenterProtocol = DKChatPresenter(view: view)
        view.presenter = presenter
    }
    
}
