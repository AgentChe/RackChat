//
//  ScreenManager.swift
//  RACK
//
//  Created by Алексей Петров on 28/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Foundation

class ScreenManager {
    
    static let showKey: String = "showKey"
    static let currentScreen: String = "currentScreen"
    
    public struct ScreenManagerEntryTypes {
        static let showMain: String = "showMain"
        static let showTest: String = "showTest"
    }
    
    public struct ScreenManagerTestEntryScreen {
        static let birthdayAndCity: String = "birthdayAndCity"
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
    }
    
    func showMian() {
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }

    func showRegistration() {
        AppDelegate.shared.rootViewController.switchToLogin()
    }
}
