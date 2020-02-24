//
//  DKChatComponentProtocols.swift
//  DatingKit_Example
//
//  Created by Алексей Петров on 23.11.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public struct DKChatConstants {
    
    public static let sectionsCount: Int = 2
    public static let unsendetSectionNumber: Int = 1
    public static let sendetSectionNumber: Int = 0
    
    public enum CellsIndefires: String {
        public typealias RawValue = String
        case userTextMessage
        case userImageMessage
        case partnerTextMessage
        case partnerImageMessage
    }
    
    public enum CellStates {
        case load
        case sendet
        case error
    }
}

public protocol ChatPresenterProtocol: class {
    var view: ChatViewProtocol? { get set }
    var user: UserShow! { get }
    var tableDataSource: UITableViewDataSource { get }
    var messagesCount: Int { get }
    
    func configure(chat: ChatItem)
    func disconnect()
    func send(message: Message)
    func pagintaion(for indexPath: IndexPath)
    func deleteUnsendet(message: Message)
}

public protocol MenuViewProtocol: class {
    func show(_ show: Bool)
}

public protocol ChatNoViewProtocol: class {
    
    var icon: UIImage { get set }
    var title: String { get set }
    var subTitle: String { get set }
}

public protocol ChatViewProtocol: class {
    var menuView: MenuViewProtocol { get set }
    var noView: ChatNoViewProtocol { get set }
    var tableView: UITableView { get set }
    var textInputView: DKChatBottomView { get set }
    
    func reload()
    func showNoView(_ show: Bool)
    func addMessage(at indexPath: IndexPath)
    func deleteMessage(at indexPath: IndexPath)
    func showError(with message: Message)
}

public extension UITableView {
    
    func register(_ nib: UINib, with identifier: DKChatConstants.CellsIndefires) {
        register(nib, forCellReuseIdentifier: identifier.rawValue)
    }
    
}

public extension UITableView {

    internal func dequeueUserTextCell(for indexPath: IndexPath) ->  DKUserMessageTableViewCell {
        
        guard let cell: DKUserMessageTableViewCell = dequeueReusableCell(withIdentifier: DKChatConstants.CellsIndefires.userTextMessage.rawValue, for: indexPath) as? DKUserMessageTableViewCell else {
            return DKUserMessageTableViewCell()
        }
        
        return cell
    }
    
    internal func dequeuePartnerTextCell(for indexPath: IndexPath) ->  DKPartnerMessageTableViewCell {
        
        guard let cell: DKPartnerMessageTableViewCell = dequeueReusableCell(withIdentifier: DKChatConstants.CellsIndefires.partnerTextMessage.rawValue, for: indexPath) as? DKPartnerMessageTableViewCell else {
            return DKPartnerMessageTableViewCell()
        }
        
        return cell
    }
    
    internal func dequeueUserImageCell(for indexPath: IndexPath) -> DKUserImageTableViewCell! {
        guard let cell: DKUserImageTableViewCell = dequeueReusableCell(withIdentifier: DKChatConstants.CellsIndefires.userImageMessage.rawValue, for: indexPath) as? DKUserImageTableViewCell else {
            return DKUserImageTableViewCell()
        }
        
        return cell
    }
    
    internal func dequeuePartnerImageCell(for indexPath: IndexPath) ->  DKPartnerIMewssageImageTableViewCell {
        guard let cell: DKPartnerIMewssageImageTableViewCell = dequeueReusableCell(withIdentifier: DKChatConstants.CellsIndefires.partnerImageMessage.rawValue, for: indexPath) as? DKPartnerIMewssageImageTableViewCell else {
            return DKPartnerIMewssageImageTableViewCell()
        }
               
        return cell
    }
}
