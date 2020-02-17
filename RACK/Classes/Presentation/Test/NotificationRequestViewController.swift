//
//  NotificationRequestViewController.swift
//  RACK
//
//  Created by Алексей Петров on 03/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import UserNotifications
import DatingKit

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
        
        //        PaymentFlow.shared.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pay" {
//            let paygate: PaygateViewController = segue.destination as! PaygateViewController
//            let config: ConfigBundle = sender as! ConfigBundle
//            //            PurchaseManager.shared.loadProducts()
//            paygate.delegate = self
//            paygate.config(bundle: config)
        }
    }
    
}

//extension NotificationRequestViewController: PaygateViewDelegate {
//
//    func purchaseWasEndet() {
//        self.performSegue(withIdentifier: "start_new", sender: nil)
//    }
//
//}

extension NotificationRequestViewController: NotificationDelegate {
    
    func notificationRequestWasEnd(succses: Bool) {
        //        dismiss(animated: true, completion: nil)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.firstLabelView.alpha = 0.0
            self.lastLabelView.alpha = 0.0
        }) { (succses) in
            UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
            ScreenManager.shared.showMian()
            
//            if PurchaseManager.shared.showUponLogin {
//                PurchaseManager.shared.getConfigBundle { (config) in
//                    self.performSegue(withIdentifier: "pay", sender: config)
//                    return
//                }
//            }
            //            PaymentFlow.shared.start()
//            self.performSegue(withIdentifier: "start_new", sender: nil)
            //            ScreenManager.shared.showMian()
        }
        
    }
    
}


//extension NotifyViewController: PaymentFlowDelegate {
//
//    func purchase() {
//
//    }
//
//    func paymentInfoWasLoad(config bundle: ConfigBundle) {
//        //        ScreenManager.shared.showMian()
//    }
//
//    func paymentSuccses() {
//
//    }
//
//    func error() {
//
//    }
//
//}
