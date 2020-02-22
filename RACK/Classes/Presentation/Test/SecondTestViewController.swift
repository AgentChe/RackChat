//
//  SecondTestViewController.swift
//  RACK
//
//  Created by Алексей Петров on 25/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import NotificationBannerSwift


class SecondTestViewController: UIViewController {

    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var quiqButton: UIButton!
    @IBOutlet weak var virtualButton: UIButton!
    @IBOutlet weak var quikView: UIView!
    @IBOutlet weak var virtView: UIView!
    @IBOutlet weak var meetView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amplitude.instance()?.log(event: .secondOnboardingScr)
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.secondTest, forKey: ScreenManager.currentScreen)
    }
    
    @IBAction func startTapOnVirt(_ sender: Any) {
        virtView.alpha = 0.6
        quiqButton.isEnabled = false
        meetButton.isEnabled = false
    }
    
    @IBAction func tapOnVirt(_ sender: Any) {
        virtView.alpha = 1.0
        quiqButton.isEnabled = true
        meetButton.isEnabled = true
        DatingKit.user.set(aim: .virt) { (status) in
            switch status {
            case .succses:
                self.performSegue(withIdentifier: "last", sender: nil)
                break
            case . noInternetConnection:
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self.navigationController)
                break
            default:
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                break
            }
        }
//        User.shared.set(aim: .virt) {
//            self.performSegue(withIdentifier: "last", sender: nil)
//        }
    }
    
    @IBAction func endTapOnVirt(_ sender: Any) {
        virtView.alpha = 1.0
        quiqButton.isEnabled = true
        meetButton.isEnabled = true
    }
    
    @IBAction func startTapOnQuik(_ sender: Any) {
        quikView.alpha = 0.6
        meetButton.isEnabled = false
        virtualButton.isEnabled = false
    }
    
    @IBAction func tapOnQuik(_ sender: Any) {
        quikView.alpha = 1.0
        meetButton.isEnabled = true
        virtualButton.isEnabled = true
        DatingKit.user.set(aim: .chats) { (status) in
             switch status {
                       case .succses:
                           self.performSegue(withIdentifier: "last", sender: nil)
                           break
                       case . noInternetConnection:
                           let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                           banner.show(on: self.navigationController)
                           break
                       default:
                           let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                           let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                           alertController.addAction(action)
                           self.present(alertController, animated: true, completion: nil)
                           break
                       }
        }
//        User.shared.set(aim: .chats) {
//            self.performSegue(withIdentifier: "last", sender: nil)
//        }
    }
    
    @IBAction func endTapOnQuik(_ sender: Any) {
        quikView.alpha = 1.0
        meetButton.isEnabled = true
        virtualButton.isEnabled = true
    }
    
    @IBAction func startTapOnMeet(_ sender: Any) {
        meetView.alpha = 0.6
        quiqButton.isEnabled = false
        virtualButton.isEnabled = false
    }
    
    @IBAction func tapOnMeet(_ sender: Any) {
        meetView.alpha = 1.0
        quiqButton.isEnabled = true
        virtualButton.isEnabled = true
        DatingKit.user.set(aim: .meetUps) { (status) in
             switch status {
                       case .succses:
                           self.performSegue(withIdentifier: "last", sender: nil)
                           break
                       case . noInternetConnection:
                           let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                           banner.show(on: self.navigationController)
                           break
                       default:
                           let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                           let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                           alertController.addAction(action)
                           self.present(alertController, animated: true, completion: nil)
                           break
                       }
        }
//        User.shared.set(aim: .meetUps) {
//            self.performSegue(withIdentifier: "last", sender: nil)
//        }
    }
    
    @IBAction func endTapOnMeet(_ sender: Any) {
        meetView.alpha = 1.0
        quiqButton.isEnabled = true
        virtualButton.isEnabled = true
    }
    
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        // Remove self from navigation hierarchy
//        guard let viewControllers = navigationController?.viewControllers,
//            let index = viewControllers.firstIndex(of: self) else { return }
//        navigationController?.viewControllers.remove(at: index)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
