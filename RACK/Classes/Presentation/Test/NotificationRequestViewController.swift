//
//  NotificationRequestViewController.swift
//  RACK
//
//  Created by Алексей Петров on 03/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationRequestViewController: UIViewController {
    
    @IBOutlet weak var lastLabelView: UIView!
    @IBOutlet weak var firstLabelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.notify, forKey: ScreenManager.currentScreen)
        UserDefaults.standard.set(true, forKey: NotificationManager.kWasShow)   //bool(forKey: NotificationManager.kWasShow) = true
        NotificationManager.shared.startManagment()
        NotificationManager.shared.delegate = self
        NotificationManager.shared.requestAccses()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pay" {
        }
    }
    
}

extension NotificationRequestViewController: NotificationDelegate {
    
    func notificationRequestWasEnd(succses: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            self.firstLabelView.alpha = 0.0
            self.lastLabelView.alpha = 0.0
        }) { (succses) in
            UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
            ScreenManager.shared.showMian()
        }
        
    }
    
}
