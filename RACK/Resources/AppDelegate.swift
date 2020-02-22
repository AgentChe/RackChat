//
//  AppDelegate.swift
//  RACK
//
//  Created by Алексей Петров on 25/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import Amplitude_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        
        PurchaseManager.shared.gettingStart()
        
        DatingKit.isLogined { (isLoginned) in
            if isLoginned {
                NotificationManager.shared.startManagment()
            }
        }

        Amplitude.instance()?.initializeApiKey("7003a76ce0c1807ae2030b1b35b20baf") //  645e522c3ac1041194071450538c9467  7003a76ce0c1807ae2030b1b35b20baf
        window?.makeKeyAndVisible()

        if let options = launchOptions, let remoteNotif = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            if let aps = remoteNotif["aps"] as? [String: Any] {
                ScreenManager.shared.showChat = true
                NotificationManager.shared.handleNotify(userInfo: aps)
            }
        }

        return true
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled: Bool = (ApplicationDelegate.shared.application(app, open: url, options: options))
        return handled
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationManager.shared.application(application: application, didReceiveRemoteNotification: userInfo)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.application(application: application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationManager.shared.application(application: application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
