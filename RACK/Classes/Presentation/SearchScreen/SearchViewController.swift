//
//  SearchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 30.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    private lazy var tableView: ProposedInterlocutorTableView = {
        let view = ProposedInterlocutorTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel = SearchViewModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        addSubviews()
        bind()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func bind() {
        viewModel
            .proposedInterlocutors
            .drive(onNext: { [weak self] proposedInterlocutors in
                self?.tableView.add(proposedInterlocutors: proposedInterlocutors)
            })
            .disposed(by: disposeBag)
        
        Signal
            .merge(viewModel.likeWasPut,
                   viewModel.dislikeWasPut)
            .emit(onNext: { [weak self] proposedInterlocutor in
                self?.tableView.remove(proposedInterlocutor: proposedInterlocutor)
            })
            .disposed(by: disposeBag)
        
        tableView
            .like
            .emit(to: viewModel.like)
            .disposed(by: disposeBag)
        
        tableView
            .dislike
            .emit(to: viewModel.dislike)
            .disposed(by: disposeBag)
    }
}
