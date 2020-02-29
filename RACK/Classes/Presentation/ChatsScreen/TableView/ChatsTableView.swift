//
//  ChatsTableView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 29/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxCocoa

final class ChatsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let didSelectChat = PublishRelay<AKChat>()
    
    private var items: [AKChat] = []
    
    private let itemsQueue = DispatchQueue(label: "chats_queue")
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        register(UINib(nibName: "СhatsTableViewCell", bundle: .main), forCellReuseIdentifier: "ChatsCell")
        
        dataSource = self
        delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
        cell.bind(chat: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: true)
        
        didSelectChat.accept(items[indexPath.row])
    }
    
    func add(chats: [AKChat]) {
        itemsQueue.sync { [weak self] in
            self?.items = chats
            
            self?.reloadData()
        }
    }
    
    func replace(chat: AKChat) {
        itemsQueue.sync { [weak self] in
            guard let index = self?.items.firstIndex(where: { $0.id == chat.id }) else {
                return
            }
            
            self?.items[index] = chat
            
            self?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}
