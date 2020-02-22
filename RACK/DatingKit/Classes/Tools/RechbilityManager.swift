//
//  RechbilityManager.swift
//  DatingKit
//
//  Created by Алексей Петров on 04.11.2019.
//

import Foundation
import Reachability

public protocol NetworkStatusListener : class {
    func networkStatusDidChange(status: Reachability.Connection)
}

public class ReachabilityManager: NSObject {
    
    public static let shared = ReachabilityManager()
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .unavailable
    }
    
    var reachabilityStatus: Reachability.Connection = .unavailable
    
    let reachability = try! Reachability()
    
    var listeners = [NetworkStatusListener]()
    
    private var foregroundNotification: NSObjectProtocol?
    private var becomeActive: NSObjectProtocol?
    
    override init() {
        super.init()
        foregroundNotification = NotificationCenter.default.addObserver(forName:
         UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) {
                   [unowned self] notification in
            self.stopMonitoring()
        }
        
        becomeActive = NotificationCenter.default.addObserver(forName:
         UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) {
                   [unowned self] notification in
            self.startMonitoring()
        }
    }

    @objc func reachabilityChanged(notification: Notification) {
        
        let reachability = notification.object as! Reachability

        switch reachability.connection {
        case .unavailable:
            debugPrint("Network became unreachable")
        case .wifi:
            debugPrint("Network reachable through WiFi")
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        case .none:
            break
        }
        
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.connection)
        }
    }
    
    
    public func startMonitoring() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            debugPrint("Could not start reachability notifier")
        }
    }
    
    public func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
    
    
    public func addListener(listener: NetworkStatusListener){
        listeners.append(listener)
    }
    
    public func removeListener(listener: NetworkStatusListener){
        listeners = listeners.filter{ $0 !== listener}
    }
}
