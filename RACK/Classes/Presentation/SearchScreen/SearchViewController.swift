//
//  SearchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 30.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import RxSwift

protocol SearchViewControllerDelegate: class {
    func wasDismiss()
    func newChat(chat: Chat)
}

final class SearchViewController: UIViewController {
    private enum Scene {
        case searching, matching, none
    }
    
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.startColor = .clear
        view.endColor = .darkGray
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shadowView: GradientView = {
        let view = GradientView()
        view.startColor = .white
        view.endColor = .white
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var contentViewTopConstraint: NSLayoutConstraint!
    private var shadowViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: SearchViewControllerDelegate?
    
    private var user: User?
    
    private var initialTouchPoint = CGPoint(x: 0, y: 0)
    
    private var interlocutorResponseTimer: Timer?
    
    private var currentScene: Scene = .searching
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        configure()
        
        AppStateProxy.ApplicationProxy
            .willResignActive
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.user
            .drive(onNext: { [weak self] user in
                self?.user = user
                
                self?.applySearchScene()
            })
            .disposed(by: disposeBag)
        
        var searchingQueueId: SearchingQueueId?
        
        viewModel.event
            .drive(onNext: { [weak self] event in
                guard let `self` = self else {
                    return
                }
                
                switch event {
                case .registered(let queueId):
                    searchingQueueId = queueId
                case .proposedInterlocutor(let matchProposeds):
                    guard let proposedInterlocutor = matchProposeds.first(where: { $0.queueId == searchingQueueId }) else {
                        return
                    }
                    
                    self.stopInterlocutorCountdown()
                    
                    self.removeAllScenes()
                    self.applyMatchScene(proposedInterlocutor: proposedInterlocutor)
                case .proposedInterlocutorRefused(let queueIds):
                    guard let queueId = searchingQueueId, queueIds.contains(queueId) else {
                        return
                    }
                    
                    self.stopInterlocutorCountdown()
                    
                    self.removeAllScenes()
                    self.applySearchScene()
                case .proposedInterlocutorConfirmed(let stub):
                    guard let forCurrentQueue = stub.first(where: { $0.0 == searchingQueueId }) else {
                        return
                    }
                    
                    self.startInterlocutorCountdown(seconds: forCurrentQueue.1)
                case .coupleFormed(let stub):
                    guard let (_, chat) = stub.first(where: { $0.0 == searchingQueueId }) else {
                        return
                    }
                    
                    self.dismiss(animated: true)
                    self.delegate?.newChat(chat: chat)
                case .closed(let queueIds):
                    guard self.currentScene == .matching, let queueId = searchingQueueId, queueIds.contains(queueId) else {
                        return
                    }
                    
                    self.stopInterlocutorCountdown()
                    
                    self.removeAllScenes()
                    self.applySearchScene()
                    
                    self.viewModel.register()
                case .technical(let technicalEvent):
                    switch technicalEvent {
                    case .socketConnected:
                        self.viewModel.register()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.connect()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIApplication.shared.isIdleTimerDisabled = false
        
        currentScene = .none
        
        viewModel.close()
        
        delegate?.wasDismiss()
        
        stopInterlocutorCountdown()
        
        super.dismiss(animated: flag, completion: completion)
    }
    
    private func configure() {
        view.addSubview(gradientView)
        view.addSubview(shadowView)
        view.addSubview(contentView)
        
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 450).isActive = true 
        
        shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        shadowViewTopConstraint = shadowView.topAnchor.constraint(equalTo: view.topAnchor, constant: 84)
        shadowViewTopConstraint.isActive = true
        
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        contentViewTopConstraint.isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let contentViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(contentViewPanGesture(_:)))
        contentView.addGestureRecognizer(contentViewPanGesture)
    }
    
    private func removeAllScenes() {
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    private func applySearchScene() {
        guard let user = self.user else {
            return
        }
        
        currentScene = .searching
        
        fullScreen(full: false)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.backgroundColor = .clear
            self?.shadowView.startColor = .white
            self?.shadowView.endColor = .white
        }
        
        let searchView = SearchView.instanceFromNib()
        
        searchView.setup(user: user)
        searchView.frame = CGRect(x: 0,
                                  y: 20.0,
                                  width: contentView.frame.size.width,
                                  height: contentView.frame.size.height)
        
        contentView.addSubview(searchView)
    }
    
    private func applyMatchScene(proposedInterlocutor: ProposedInterlocutor) {
        guard let user = self.user else {
            return
        }
        
        currentScene = .matching

        fullScreen(full: true) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.contentView.backgroundColor = .clear
                
                if let colorBegin = proposedInterlocutor.gradientColorBegin, let colorEnd = proposedInterlocutor.gradientColorEnd {
                    self?.shadowView.startColor = UIColor.hexStringToUIColor(hex: colorBegin)
                    self?.shadowView.endColor = UIColor.hexStringToUIColor(hex: colorEnd)
                }
            }
        }
        
        let matchView = MatchView.instanceFromNib()
        
        matchView.onSure = { [weak self] in
            matchView.waitForPatnerAnimation()
            
            self?.viewModel.sure()
        }
        
        matchView.onSkip = { [weak self] in
            self?.removeAllScenes()
            self?.applySearchScene()
            
            self?.viewModel.skip()
        }

        matchView.setup(proposedInterlocutor: proposedInterlocutor, user: user)
        matchView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: contentView.frame.size.width,
                                 height: contentView.frame.size.height + 34.0)

        contentView.addSubview(matchView)
    }
    
    private func applyTimeOutScene() {
        fullScreen(full: false)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.backgroundColor = .clear
            self?.shadowView.startColor = .white
            self?.shadowView.endColor = .white
        }
        
        let timeOutView = TimeOutView.instanceFromNib()
        
        timeOutView.onNewSearch = { [weak self] in
            self?.removeAllScenes()
            self?.applySearchScene()
            
            self?.viewModel.register()
        }
        
        timeOutView.frame = CGRect(x: 0,
                                   y: 20.0,
                                   width: contentView.frame.size.width,
                                   height: contentView.frame.size.height)
        
        contentView.addSubview(timeOutView)
    }
    
    private func startInterlocutorCountdown(seconds: Int) {
        interlocutorResponseTimer?.invalidate()
        
        interlocutorResponseTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
            self?.viewModel.close()
            
            self?.removeAllScenes()
            self?.applyTimeOutScene()
        }
    }
    
    private func stopInterlocutorCountdown() {
        interlocutorResponseTimer?.invalidate()
        interlocutorResponseTimer = nil
    }
    
    @objc private func contentViewPanGesture(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: view.frame.size.width, height: view.frame.size.height)
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 200 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        default:
            break
        }
    }
    
    private func fullScreen(full: Bool, completion: (() -> Void)? = nil) {
        shadowViewTopConstraint.constant = full ? 0 : 84
        contentViewTopConstraint.constant = full ? 0 : 40

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.shadowView.cornerRadius = full ? 0 : 30
            self?.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
}
