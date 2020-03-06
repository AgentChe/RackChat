//
//  MatchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 30.10.2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import NotificationBannerSwift

enum MatchScreenState {
    case searchng
    case serchingManuality
    case foundet
    case partnerSayNot
    case timeOut
    case noOneHere
    case noOneHerewithNotifyRequest
}

protocol SearchViewDelegate: class {
    func wasDismis(searchView: MatchViewController)
    func tapOnYes()
}

class MatchViewController: UIViewController {
    @IBOutlet weak var shadowView: GardientView!
    @IBOutlet weak var matchContentView: UIView!
    
    @IBOutlet weak var shadowTop: NSLayoutConstraint!
    @IBOutlet weak var contentTop: NSLayoutConstraint!
    
    private var user: UserShow?
    private var currentMatch: DKMatch?
    
    private var fullScreen: Bool = false
    private var state: MatchScreenState = .searchng
    private var searchScene: SearchView = SearchView.instanceFromNib()
    private var matchScene: MatchView = MatchView.instanceFromNib()
    private var noScene: NoView = NoView.instanceFromNib()
    private var noOneScene: NoOneHereView = NoOneHereView.instanceFromNib()
    private var timeOutScene: TimeOutView = TimeOutView.instanceFromNib()
    
    weak var delegate: SearchViewDelegate?
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    func config(state: MatchScreenState) {
        self.state = state
    }
    
    func config(state: MatchScreenState, match: DKMatch) {
        self.state = state
        self.currentMatch = match
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        DatingKit.user.show { (userShow, status) in
            if status == .succses {
                guard let user = userShow else {
                    return
                }
                self.user = user
                
                if self.state == .searchng {
                    self.setScene(state: .searchng)
                    self.startSearch()
                }
                
                if self.state == .serchingManuality {
                    self.setScene(state: .serchingManuality)
                }
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        delegate?.wasDismis(searchView: self)
        DatingKit.search.stopAll()
        UIApplication.shared.isIdleTimerDisabled = false
        
        super.dismiss(animated: flag, completion: completion)
    }
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        fullScreen(false)
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
          
            if touchPoint.y - initialTouchPoint.y > 200 {
  
                self.dismiss(animated: true, completion: nil)
            } else {
                fullScreen(self.fullScreen)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleMatch() {
        guard let match: DKMatch = ScreenManager.shared.match else { return }
        currentMatch = match
        setScene(state: .foundet)
    }
    
    @objc func search() {
        self.startSearch()
        self.setScene(state: .searchng)
    }
    
    @objc func yes() {
        matchScene.waitForPatnerAnimation()
        self.sayYes()
    }
    
    @objc func skip() {
        noOneScene.showSearchView()
    }
    
    @objc func no() {
        self.sayNo()
    }
    
    @objc func requestNotify() {
        let alertController = UIAlertController (title: "“RACK” Would Like to Send You Notifications", message: "To manage push notifications you'll need to enable them in app's settings first", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        self.noOneScene.showSearchView()
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
    }
    
    func sayNo() {
        guard let match: DKMatch = self.currentMatch else {
            return
            
        }
        
        self.setScene(state: .searchng)
        self.startSearch()
        DatingKit.search.sayNo(matchID: match.matchID) { (status) in
            if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self)
                return
            }
        }
    }
    
    func sayYes() {
        guard let match: DKMatch = self.currentMatch else {
            return
        }
        
        DatingKit.search.sayYes(matchID: match.matchID) { (matchStatus, status) in
                   switch status {
                   case .succses:
                       switch matchStatus {
                       case .waitPartnerAnser:
                            break
                       case .timeOut:
                        self.setScene(state: .timeOut)
                       case .deny:
                        self.setScene(state: .partnerSayNot)
                       case .confirmPending:
                           self.dismiss(animated: true) {
                               self.delegate?.tapOnYes()
                           }
                       case .lostChat:
                           break
                       case .report:
                           break
                       case .cantAnswer:
                           break
                       }
                       
                   case .noInternetConnection:
                    self.matchScene.showButtons()
                       switch matchStatus {
                       case .cantAnswer:
                           let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                           banner.show(on: self)
                           break
                           
                       case .waitPartnerAnser:
                           let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                           banner.show(on: self)
                           break
                                              
                       default: break
                       }
                   case .needPayment:
                        self.matchScene.showButtons()
                       break
                   case .forbitten:
                    if matchStatus == .cantAnswer {
                        self.setScene(state: .timeOut)
                    }
                   default:
                       break
                   }
               }
    }
    
    func startSearch() {
        fullScreen(false)
        guard let userShow: UserShow = self.user else { return }
        DatingKit.search.startSearch(email: userShow.email) { [weak self] (match, status) in
            switch status {
            case .succses:
                self!.currentMatch = match
                self!.setScene(state: .foundet)
            case .timeOut:
                self!.setScene(state: .noOneHere)
            default:
                break
            }
        }
    }
    
    private func setScene(state: MatchScreenState) {
        for view in matchContentView.subviews{
            view.removeFromSuperview()
        }
        
        self.state = state
        
        switch state {
        case .searchng:
            setSearchScene(mode: .auto)
            break
        case .serchingManuality:
            setSearchScene(mode: .manualy)
            break
        case .foundet:
            setFoundScene()
            break
        case .partnerSayNot:
            setNoScene()
            break
        case .timeOut:
            setTimeOutScene()
            break
        case .noOneHere:
            setNoOneScene()
            break
        case .noOneHerewithNotifyRequest:
            break
        }
        
    }
    
    func setTimeOutScene() {
        matchScene.removeFromSuperview()
        fullScreen = false
        fullScreen(false)
        UIView.animate(withDuration: 0.4) {
            self.matchContentView.backgroundColor = .clear
            self.shadowView.startColor = .white
            self.shadowView.endColor = .white
            
        }
        timeOutScene.frame = CGRect(x: 0,
                                    y: 20.0,
                                    width: matchContentView.frame.size.width,
                                    height: matchContentView.frame.size.height)
        timeOutScene.newSearch.addTarget(self, action: #selector(search), for: .touchUpInside)
        matchContentView.addSubview(timeOutScene)

    }
    
    func setSearchScene(mode: SearchViewStates) {
        timeOutScene.removeFromSuperview()
        noOneScene.removeFromSuperview()
        searchScene.removeFromSuperview()
        searchScene = SearchView.instanceFromNib()
        UIView.animate(withDuration: 0.4) {
            self.matchContentView.backgroundColor = .clear
            self.shadowView.startColor = .white
            self.shadowView.endColor = .white
            
        }
        matchScene.removeFromSuperview()
        guard let userShow: UserShow = self.user else { return }
        fullScreen = mode == .auto ? false : true
        fullScreen(mode == .auto ? false : true)
        searchScene.config(type: mode, user: userShow)
        searchScene.frame = CGRect(x: 0,
                                   y: 20.0,
                                   width: matchContentView.frame.size.width,
                                   height: matchContentView.frame.size.height)
        searchScene.newSearchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        matchContentView.addSubview(searchScene)
        
    }
    
    func setFoundScene() {
        searchScene.removeFromSuperview()
        matchScene.removeFromSuperview()
        matchScene = MatchView.instanceFromNib()
        guard let userShow: UserShow = self.user else { return }
        guard let match: DKMatch = self.currentMatch else { return }
        fullScreen = true
        fullScreen(true) {
            UIView.animate(withDuration: 0.4) {
                self.matchContentView.backgroundColor = .clear
                self.shadowView.startColor = UIColor.hexStringToUIColor(hex: match.gradient.gradientStartColor)
                self.shadowView.endColor = UIColor.hexStringToUIColor(hex: match.gradient.gradientEndColor)
                
            }
        }
        
        matchScene.config(match: match, user: userShow)
        matchScene.frame = CGRect(x: 0,
                                  y: 0,
                                  width: matchContentView.frame.size.width,
                                  height: matchContentView.frame.size.height + 34.0)
        
        matchScene.sureButton.addTarget(self, action: #selector(yes), for: .touchUpInside)
        matchScene.skipButton.addTarget(self, action: #selector(no), for: .touchUpInside)
        
        matchContentView.addSubview(matchScene)
    }
    
    func setNoOneScene() {
        searchScene.removeFromSuperview()
        matchScene.removeFromSuperview()
        fullScreen = true
        fullScreen(true)
        noOneScene.config()
        noOneScene.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        noOneScene.newSearch.addTarget(self, action: #selector(search), for: .touchUpInside)
        noOneScene.sureButton.addTarget(self, action: #selector(requestNotify), for: .touchUpInside)
        noOneScene.skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
        
        
        noOneScene.frame = CGRect(x: 0,
                                  y: 0,
                                  width: matchContentView.frame.size.width,
                                  height: matchContentView.frame.size.height + 34.0)
         matchContentView.addSubview(noOneScene)
    }
    
    func setNoScene()  {
        guard let match: DKMatch = self.currentMatch else { return }
        fullScreen = true
        fullScreen(true)
        noScene.config(match: match)
        noScene.newSearchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        noScene.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        noScene.frame = CGRect(x: 0,
                               y: 0,
                               width: matchContentView.frame.size.width,
                               height: matchContentView.frame.size.height + 34.0)
        matchContentView.addSubview(noScene)
    }
    
    func fullScreen(_ full: Bool, completion: (() -> Void)? = nil) {
        shadowTop.constant = full ? 0 : 84
        contentTop.constant = full ? 0 : 40
        
        UIView.animate(withDuration: 0.5, animations: {
            self.shadowView.cornerRadius = full ? 0 : 30
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
}
