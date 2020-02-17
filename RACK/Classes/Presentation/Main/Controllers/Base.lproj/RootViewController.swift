//
//  RootViewController.swift
//  RACK
//
//  Created by Алексей Петров on 28/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit

class RootViewController: UIViewController {

    private var current: UIViewController
    
    init() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Splash", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "splash")
        self.current = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
        PaymentFlow.shared.delegate = self
        PaymentFlow.shared.start()
    }
    
    @objc private func login() {
        switchToLogin()
    }
    
    func showLoginScreen() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "registr")
        addChild(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = viewController
    }
    
    
    func showMainScreen() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        addChild(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = viewController
    }
    
    func showTestScreen() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
//        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "rules")
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "setAgeAndCity")
        animateFadeTransition(to: viewController)
//        let navVC =  UINavigationController(rootViewController: viewController)
//        addChild(navVC)
//        navVC.view.frame = view.bounds
//        view.addSubview(navVC.view)
//        navVC.didMove(toParent: self)
//        current.willMove(toParent: nil)
//        current.view.removeFromSuperview()
//        current.removeFromParent()
//        current = navVC
    }
    
    func showTestScreen(name: String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: name)
        let navVC =  RegistrationNavigationController(rootViewController: viewController)
        addChild(navVC)
        navVC.view.frame = view.bounds
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = navVC
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        new.view.frame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        current.willMove(toParent: nil)
        addChild(new)
        transition(from: current, to: new, duration: 0.3, options: [], animations: {
            new.view.frame = self.view.bounds
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()  //1
        }
    }
    
    func switchToMainScreen() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainScreen = mainStoryboard.instantiateViewController(withIdentifier: "main")
        animateFadeTransition(to: mainScreen)
    }
    
    func switchToLogin() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "registr")
        animateFadeTransition(to: viewController)
    }
    
    func showSplash() {
        let splashStoryboard: UIStoryboard = UIStoryboard(name: "Splash", bundle: nil)
        let splashScreen = splashStoryboard.instantiateViewController(withIdentifier: "splash")
        animateFadeTransition(to: splashScreen)
        
//        PaymentFlow.shared.start()
    }
    
}

extension RootViewController: PaymentFlowDelegate {
    
    func paymentInfoWasLoad(config bundle: ConfigBundle) {
//         User.shared.start()
    }
    
    func paymentSuccses() {
        
    }
    
    func error() {
//         User.shared.start()
    }
    
    func purchase() {
        
    }
    
    
}

//exception RootViewController: PaymentFlowDelegate  {

//}
