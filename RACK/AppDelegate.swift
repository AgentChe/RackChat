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
import DatingKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // FB
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
