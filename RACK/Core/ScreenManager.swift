//
//  ScreenManager.swift
//  RACK
//
//  Created by Алексей Петров on 28/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Foundation
import DatingKit

class ScreenManager {
    
    static let showKey: String = "showKey"
    static let currentScreen: String = "currentScreen"
    
    public struct ScreenManagerEntryTypes {
        static let showMain: String = "showMain"
        static let showTest: String = "showTest"
    }
    
    public struct ScreenManagerTestEntryScreen {
        static let rules: String = "rules"
        static let gender: String = "gender"
        static let firstTest: String = "firstTest"
        static let secondTest: String = "secondTest"
        static let triedTest: String = "triedTest"
        static let rand: String = "rand"
        static let notify: String = "notify"
    }
    
    static let shared = ScreenManager()
    
    var pushChat: ChatItem?
    var chatItemOnScreen: ChatItem?
    var match: DKMatch?
    var showChat: Bool = false
    var autoChat: Bool = false
    
    weak var onScreenController: UIViewController?
    
    weak var generalController: UIViewController?
    
    init() {
        
    }
    
    func startManagment() {
        // FIXME:
//        AppDelegate.shared.rootViewController.showTestScreen()

        DatingKit.isLogined { (isLogined) in
            if isLogined {
                if let status:String = UserDefaults.standard.object(forKey: ScreenManager.showKey) as? String {
                    if status == ScreenManagerEntryTypes.showMain {

                        AppDelegate.shared.rootViewController.showMainScreen()
                        return
                    }

                    if status == ScreenManagerEntryTypes.showTest {
                        if let cureent: String = UserDefaults.standard.object(forKey: ScreenManager.currentScreen) as? String {
                            AppDelegate.shared.rootViewController.showTestScreen(name: cureent)
                            return
                        } else {
                            AppDelegate.shared.rootViewController.showTestScreen()
                            return
                        }
                    }
                } else {
                    AppDelegate.shared.rootViewController.showMainScreen()
                }
            } else {
                AppDelegate.shared.rootViewController.showLoginScreen()
            }
        }
        
//        if User.shared.isLogined() {
//            AppDelegate.shared.rootViewController.showMainScreen()
//        } else {
//            AppDelegate.shared.rootViewController.showLoginScreen()
//        }
    }
    
    func showMian() {
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
//
    func showRegistration() {
        AppDelegate.shared.rootViewController.switchToLogin()
    }
//
//    func showProfile() {
//        generalController?.performSegue(withIdentifier: "profile", sender: nil)
//    }
    
    func showSplash() {
        AppDelegate.shared.rootViewController.showSplash()
    }
    
//    func startOnboarding() {
//        generalController?.performSegue(withIdentifier: "Onboarding", sender: nil)
//    }
//    
//    func setGeneralController(_ viewController: UIViewController) {
//        generalController = viewController
//    }
//    
//    func showChat() {
//        
//        self.generalController?.performSegue(withIdentifier: "chat", sender: nil)
//        
//    }
//    
//    func showPaygate() {
//        generalController?.performSegue(withIdentifier: "paygate", sender: nil)
//    }
//    
//    func showError(text: String) {
//        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//            switch action.style{
//            case .default:
//                print("default")
//                
//            case .cancel:
//                print("cancel")
//                
//            case .destructive:
//                print("destructive")
//                
//                
//            }}))
//        onScreenController!.present(alert, animated: true, completion: nil)
//    }
    
    
}
