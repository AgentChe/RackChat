//
//  DKUserImageTableViewCell.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AlamofireImage

open class DKUserImageTableViewCell: UITableViewCell {
    
    @IBOutlet open var messageImageView: UIImageView!
    @IBOutlet open var errorButton: UIButton!
    @IBOutlet open var activityIndicator: UIActivityIndicatorView!
    @IBOutlet open weak var leadingConstarait: NSLayoutConstraint!
    
    var handler: (_ cell : DKUserImageTableViewCell) -> Void = {_ in }
    private var message: Message!
    private var presenter: ChatPresenterProtocol!

    override open func awakeFromNib() {
        super.awakeFromNib()
        errorButton.addTarget(self, action: #selector(tapOnError), for: .touchUpInside)
    }
    
    open func config(message: UIMessage, presenter: ChatPresenterProtocol) {
        self.presenter = presenter
        self.message = message.message
        
        if let image: UIImage = message.image {
            messageImageView.image = image
        } else {
            guard let url: URL = URL(string: message.body) else { return }
            messageImageView.af_setImage(withURL: url)
        }
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
    
    open func config(message: Message, state: DKChatConstants.CellStates) {
        self.message = message
        
        if let image: UIImage = message.sendetImage {
            messageImageView.image = image
        } else {
            guard let url: URL = URL(string: message.body) else { return }
            messageImageView.af_setImage(withURL: url)
        }
    
        switch state {
        case .load:
            showActivity(true)
        case .sendet:
            showActivity(false)
        case .error:
            break
        }
    }
    
    @objc func tapOnError() {
        guard presenter != nil else { return }
        guard message != nil else { return }
        presenter.view?.showError(with: message)
    }
     
    open func showError(_ show: Bool) {
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
    
    override open func prepareForReuse() {
        messageImageView.image = UIImage()
        leadingConstarait.constant = 16.0
        self.layoutIfNeeded()

    }

}
