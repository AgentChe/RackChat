//
//  DKUserMessageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

open class DKUserMessageTableViewCell: UITableViewCell {

    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet public weak var messageLabel: UILabel!
    @IBOutlet public weak var errorButton: UIButton!
    @IBOutlet public weak var leadingConstarait: NSLayoutConstraint!
    
    var handler: (_ cell:DKUserMessageTableViewCell) -> Void = {_ in }
    private var message: Message!
    private var presenter: ChatPresenterProtocol!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        errorButton.addTarget(self, action: #selector(tapOnError), for: .touchUpInside)
    }
    
    public func config(message: UIMessage, presenter: ChatPresenterProtocol) {
        self.presenter = presenter
        self.message = message.message
        messageLabel.text = message.body
        switch message.sendingState {
        case .sending:
            showActivity(true)
        case .sendet:
            showActivity(false)
        case .error:
            showError(true)
        case .none:
            break
        }
    }
    
    public func config(message: Message, state: DKChatConstants.CellStates) {
        self.message = message
        messageLabel.text = message.body
        switch state {
        case .load:
            showActivity(true)
        case .sendet:
            showActivity(false)
        default:
            break
        }
    }
    
    @objc func tapOnError() {
        guard presenter != nil else { return }
        guard message != nil else { return }
        presenter.view?.showError(with: message)
    }
    
    public func showError(_ show: Bool) {
        showActivity(false)
        leadingConstarait.constant = show ? 56.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    private func showActivity(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.activityIndicator.alpha = show ? 1.0 : 0.0
        }
    }
    
    override public func prepareForReuse() {
         messageLabel.text = ""
         leadingConstarait.constant = 16.0
         self.layoutIfNeeded()

     }

}
