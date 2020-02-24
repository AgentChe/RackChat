//
//  ChatViewController.swift
//  RACK
//
//  Created by Алексей Петров on 16/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

final class ChatViewController: UIViewController {
    @IBOutlet private weak var input: DKChatBottomView!
    @IBOutlet private weak var menuCell: DKMenuCell!
    @IBOutlet private weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var noMessageView: UIStackView!
    @IBOutlet private weak var noMessagesTitleLabel: UILabel!
    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var navView: UIView!
    
    private var menuImageView: UIImageView!
    private var barItem: UIBarButtonItem?
    
    private var chat: AKChat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationItem.titleView = navView
        navigationItem.largeTitleDisplayMode = .never
        
        menuImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
                let widthConstraint = NSLayoutConstraint(item: menuImageView!,
                                                         attribute: NSLayoutConstraint.Attribute.width,
                                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                                         toItem: nil,
                                                         attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 48)
                let heightConstraint = NSLayoutConstraint(item: menuImageView!,
                                                         attribute: NSLayoutConstraint.Attribute.height,
                                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                                         toItem: nil,
                                                         attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 48)
                menuImageView.addConstraints([widthConstraint, heightConstraint])
        
        
        if let interlocutorAvatarPath = chat.interlocutorAvatarPath,
            let interlocutorAvatarUrl = URL.combain(domain: GlobalDefinitions.ChatService.restDomain, path: interlocutorAvatarPath){
            menuImageView.kf.setImage(with: interlocutorAvatarUrl)
        }
        
        barItem = UIBarButtonItem(customView: menuImageView)
        navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    func bind(chat: AKChat) {
        self.chat = chat
    }
}
