//
//  DKUserMessageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

final class DKUserMessageTableViewCell: UITableViewCell {
    @IBOutlet public weak var messageLabel: UILabel!
    
    private var message: Message!
    private var presenter: ChatPresenterProtocol!
    
    func config(message: UIMessage, presenter: ChatPresenterProtocol) {
        self.presenter = presenter
        self.message = message.message
        messageLabel.text = message.body
    }
    
    func config(message: Message, state: DKChatConstants.CellStates) {
        self.message = message
        messageLabel.text = message.body
    }
    
    @objc func tapOnError() {
        guard presenter != nil else { return }
        guard message != nil else { return }
        presenter.view?.showError(with: message)
    }
}
