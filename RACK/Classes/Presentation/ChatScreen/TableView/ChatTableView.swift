//
//  ChatTableView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 24/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let viewedMessaged = PublishRelay<AKMessage>()
    let reachedTop = PublishRelay<Void>()
    
    private var items: [AKMessage] = []
    private var itemsCount = 0
    
    init() {
        super.init(frame: .zero, style: .plain)
        
        register(UINib(nibName: "InterlocutorImageTableCell", bundle: .main), forCellReuseIdentifier: "InterlocutorImageTableCell")
        register(UINib(nibName: "InterlocutorTextTableCell", bundle: .main), forCellReuseIdentifier: "InterlocutorTextTableCell")
        register(UINib(nibName: "MyTextTableCell", bundle: .main), forCellReuseIdentifier: "MyTextTableCell")
        register(UINib(nibName: "MyImageTableCell", bundle: .main), forCellReuseIdentifier: "MyImageTableCell")
        
        dataSource = self
        delegate = self
        
        transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let identifier: String
        
        switch item.type {
        case .text:
            identifier = item.isOwner ? "MyTextTableCell" : "InterlocutorTextTableCell"
        case .image:
            identifier = item.isOwner ? "MyImageTableCell" : "InterlocutorImageTableCell"
        }
        
        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        (cell as? ChatTableCell)?.bind(message: item)
    
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let message = items[indexPath.row]
        viewedMessaged.accept(message)
        
        if indexPath.row == itemsCount - 1 {
            reachedTop.accept(Void())
        }
    }
    
    func add(messages: [AKMessage]) {
        items.append(contentsOf: messages)
        itemsCount = items.count
        
        let isScrollAtBottom = indexPathsForVisibleRows?.contains(IndexPath(row: 0, section: 0)) ?? false
        
        
        items.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
        
        reloadData()
        
        if isScrollAtBottom {
            let indexPath = IndexPath(row: 0, section: 0)
            scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
