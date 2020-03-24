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
    
    private lazy var noProposedInterlocutorsView: NoProposedInterlocutorsView = {
        let view = NoProposedInterlocutorsView()
        view.isHidden = true 
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
        view.backgroundColor = .white
        
        addSubviews()
        bind()
        
        viewModel.downloadProposedInterlocutors.accept(Void())
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(noProposedInterlocutorsView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        noProposedInterlocutorsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noProposedInterlocutorsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        noProposedInterlocutorsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        noProposedInterlocutorsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func bind() {
        viewModel
            .user
            .drive(onNext: { [weak self] user in
                guard let user = user else {
                    return
                }
                
                self?.noProposedInterlocutorsView.setup(user: user)
            })
            .disposed(by: disposeBag)
        
        noProposedInterlocutorsView
            .refresh
            .emit(to: viewModel.downloadProposedInterlocutors)
            .disposed(by: disposeBag)
        
        noProposedInterlocutorsView
            .back
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        noProposedInterlocutorsView
            .notificationSettings
            .emit(onNext: { [weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "NotifyEnablingViewController")
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView
            .changeItemsCount
            .emit(onNext: { [weak self] count in
                let isEmpty = count == 0
                
                self?.tableView.isHidden = isEmpty
                self?.noProposedInterlocutorsView.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        
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
        
        viewModel
            .needPayment
            .emit(onNext: { [weak self] in
                self?.showPaygateScreen()
            })
            .disposed(by: disposeBag)
    }
    
    private func showPaygateScreen() {
        let storyboard = UIStoryboard(name: "Payment", bundle: .main)
        let vc = storyboard.instantiateInitialViewController() as! PaymentViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        vc.delegate = self
        
        present(vc, animated: true)
    }
}

extension SearchViewController: PaymentViewControllerDelegate {
    func wasClosed() {
        navigationController?.popViewController(animated: true)
    }
    
    func wasPurchased() {
        viewModel.downloadProposedInterlocutors.accept(Void())
    }
}
