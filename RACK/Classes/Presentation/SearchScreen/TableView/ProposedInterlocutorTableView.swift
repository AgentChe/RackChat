//
//  ProposedInterlocutorTableView.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ProposedInterlocutorTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private(set) lazy var like: Signal = _like.asSignal()
    private let _like = PublishRelay<ProposedInterlocutor>()
    
    private(set) lazy var dislike: Signal = _dislike.asSignal()
    private let _dislike = PublishRelay<ProposedInterlocutor>()
    
    private var elements: [ProposedInterlocutor] = []
    
    private let queue = DispatchQueue(label: "proposed_interlocutor_table_queue")
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .grouped)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let proposedInterlocutor = elements[indexPath.row]
        
        let cell = dequeueReusableCell(withIdentifier: String(describing: ProposedInterlocutorsTableCell.self), for: indexPath) as! ProposedInterlocutorsTableCell
        cell.setup(proposedInterlocutor: proposedInterlocutor)
        
        cell.like = { [weak self] in
            self?._like.accept(proposedInterlocutor)
        }
        
        cell.dislike = { [weak self] in
            self?._dislike.accept(proposedInterlocutor)
        }
        
        return cell
    }
    
    func add(proposedInterlocutors: [ProposedInterlocutor]) {
        queue.sync { [weak self] in
            self?.elements.append(contentsOf: proposedInterlocutors)
        
            self?.reloadData()
        }
    }
    
    func remove(proposedInterlocutor: ProposedInterlocutor) {
        queue.sync { [weak self] in
            guard let index = self?.elements.firstIndex(where: { $0.id == proposedInterlocutor.id }) else {
                return
            }
            
            self?.elements.remove(at: index)
            
            self?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    private func configure() {
        separatorStyle = .none
        allowsSelection = false
        
        register(ProposedInterlocutorsTableCell.self, forCellReuseIdentifier: String(describing: ProposedInterlocutorsTableCell.self))
        
        delegate = self
        dataSource = self
    }
}
