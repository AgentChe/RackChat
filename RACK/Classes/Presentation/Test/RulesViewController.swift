//
//  RulesViewController.swift
//  RACK
//
//  Created by Алексей Петров on 18/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class RulesViewController: UIViewController {
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var confirmButton: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    @IBAction func tapOnIamOlder(_ sender: UIButton) {
        confirmButton.isEnabled = false
               sender.isEnabled = false
               activityView.isHidden = false
               UIView.animate(withDuration: 0.4) {
                   self.activityView.alpha = 1.0
               }
        DatingKit.user.confirmAge(true) { (status) in
            switch status {
            case .banned:
                break
            case .succses:
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.activityView.alpha = 0.0
                }) { (fin) in
                    self.activityView.isHidden = true
                    self.performSegue(withIdentifier: "setGender", sender: nil)
                }
                
                
                break
            case .noInternetConnection:
                UIView.animate(withDuration: 0.4, animations: {
                                   self.activityView.alpha = 0.0
                               }) { (fin) in
                                   self.activityView.isHidden = true
                                    self.confirmButton.isEnabled = true
                                       sender.isEnabled = true
                                   let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                                   banner.show(on: self.navigationController)
                               }
                
            default:
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                                                  let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                 alertController.addAction(action)
                UIView.animate(withDuration: 0.4, animations: {
                                                  self.activityView.alpha = 0.0
                                              }) { (fin) in
                                                  self.activityView.isHidden = true
                                                self.confirmButton.isEnabled = true
                                                                                      sender.isEnabled = true
                                                   self.present(alertController, animated: true, completion: nil)
                                              }
               
            }
        }
        
       
    }
    
    @IBAction func tapOnIamYonger(_ sender: UIButton) {
        confirmButton.isEnabled = false
        sender.isEnabled = false
        activityView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.activityView.alpha = 1.0
        }
        DatingKit.user.confirmAge(false) { (status) in
            switch status {
            case .banned:
                break
            case .succses:
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.activityView.alpha = 0.0
                }) { (fin) in
                    self.activityView.isHidden = true
                    self.performSegue(withIdentifier: "toYong", sender: nil)
                }
                
                
                break
            case .noInternetConnection:
                UIView.animate(withDuration: 0.4, animations: {
                                   self.activityView.alpha = 0.0
                               }) { (fin) in
                                   self.activityView.isHidden = true
                                    self.confirmButton.isEnabled = true
                                       sender.isEnabled = true
                                   let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                                   banner.show(on: self.navigationController)
                               }
                
            default:
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                                                  let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                 alertController.addAction(action)
                UIView.animate(withDuration: 0.4, animations: {
                                                  self.activityView.alpha = 0.0
                                              }) { (fin) in
                                                  self.activityView.isHidden = true
                                                self.confirmButton.isEnabled = true
                                                                                      sender.isEnabled = true
                                                   self.present(alertController, animated: true, completion: nil)
                                              }
               
            }
        }
//        User.shared.show { (user) in
//             User.shared.confirmAge(false)
//
//        }
       
    }
}
