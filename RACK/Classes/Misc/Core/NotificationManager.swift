//
//  NotificationManager.swift
//  RACK
//
//  Created by Алексей Петров on 02/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import FirebaseMessaging

protocol NotificationDelegate: class {
    func notificationRequestWasEnd(succses: Bool)
}

enum PushType: Int {
    case autoSearch = 3
    case marketing = 4
    case custom = 5
}

class NotificationManager: NSObject {
    static let kWasShow: String = "was_show_push_screen"
    static let shared: NotificationManager = NotificationManager()
    
    weak var delegate: NotificationDelegate?
    
    func startManagment() {
        if FirebaseApp.app() == nil {
               FirebaseApp.configure()
        }
//        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    func reciveNotify() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
        }
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @discardableResult
    func handleNotify(userInfo: [String: Any]) -> Bool {
        guard let type: String = userInfo["type"] as? String else {
            return false
        }
        
        if let pushType: PushType = PushType(rawValue: Int(type)!) {
            
            let request: NotificationRegister = NotificationRegister(type: pushType)
            
            RequestManager.shared.requset(request) { (result) in
                _ = 0
            }
            
            return false
            
        }
        return false
    }
    
    func requestAccses() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.registerForRemoteNotifications()
                self!.delegate?.notificationRequestWasEnd(succses: granted)
                
            }
        }
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func knockPush(enable: Bool) {
        let request: NotificationToggle = NotificationToggle(onKnocks: enable)
           RequestManager.shared.requset(request) { (result) in
               
           }
    }
    
    func usersPush(enable: Bool) {
        let request: NotificationToggle = NotificationToggle(onUsers: enable)
        RequestManager.shared.requset(request) { (result) in
            
        }
    }
    
    func messagePush(enable: Bool) {
        let request: NotificationToggle = NotificationToggle(onMessages: enable)
        RequestManager.shared.requset(request) { (result) in
            
        }
    }
    
    func matchPush(enable: Bool) {
        let request: NotificationToggle = NotificationToggle(onMatch: enable)
        RequestManager.shared.requset(request) { (result) in
            
        }
    }
    
    func getSwither(_ comletion:@escaping (_ togles: GetUserTogles?) -> Void) {
        let request: NotificationGet = NotificationGet()
        RequestManager.shared.requset(request) { (result) in
            if let toglesData: GetUserTogles = result as? GetUserTogles {
                if toglesData.httpCode == 200 {
                    comletion(toglesData)
                } else {
                    comletion(nil)
                }
            } else {
                comletion(nil)
            }
        }
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
         guard let type: String = userInfo["type"] as? String else {
                  return
              }
              
              if let pushType: PushType = PushType(rawValue: Int(type)!) {
                
                let request: NotificationRegister = NotificationRegister(type: pushType)
                
                RequestManager.shared.requset(request) { (result) in
                    _ = 0
                }
                
                if pushType == .autoSearch {
                    ScreenManager.shared.autoChat = true
                }
                
                  
              }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let token =  Messaging.messaging().fcmToken else {return}
        let dataDict:[String: String] = ["token": token]

    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
       
        guard let type: String = userInfo["type"] as? String else {
            return
        }
        
        if let pushType: PushType = PushType(rawValue: Int(type)!) {
            
            let request: NotificationRegister = NotificationRegister(type: pushType)
            
            RequestManager.shared.requset(request) { (result) in
                _ = 0
            }
        }

        completionHandler()
    }
}

extension NotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let setKeyRequest: NotificationSetKey = NotificationSetKey(parameters: ["key" : fcmToken])
        RequestManager.shared.requset(setKeyRequest) { (result) in
            _ = 0
        }
   
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
}
