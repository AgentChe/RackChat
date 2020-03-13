//
//  InterlocutorRefusedView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 13/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit

final class InterlocutorRefusedView: UIView {
    class func instanceFromNib() -> InterlocutorRefusedView {
        UINib(nibName: "InterlocutorRefusedView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! InterlocutorRefusedView
    }
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    var onNewSearch: (() -> ())?
    var onBack: (() -> ())?
    
    func setup(proposedInterlocutor: ProposedInterlocutor) {
        messageLabel.text = String(format: "you_skipped".localized, proposedInterlocutor.gender == .man ? "he".localized : "she".localized)
    }
    
    @IBAction private func newSearchTapped(_ sender: Any) {
        onNewSearch?()
    }
    
    @IBAction private func backTapped(_ sender: Any) {
        onBack?()
    }
}
