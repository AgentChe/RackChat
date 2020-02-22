//
//  FirstTestViewController.swift
//  RACK
//
//  Created by Алексей Петров on 01/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import NotificationBannerSwift


class FirstTestViewController: UIViewController {

    @IBOutlet weak var guysView: UIView!
    @IBOutlet weak var girlsView: UIView!
    @IBOutlet weak var guysAndGirls: UIView!
    @IBOutlet weak var guysButton: UIButton!
    @IBOutlet weak var girlsButton: UIButton!
    @IBOutlet weak var anyButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
         Amplitude.instance()?.log(event: .firstOnboardingScr)
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.firstTest, forKey: ScreenManager.currentScreen)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func startTapOnGuys(_ sender: Any) {
        guysView.alpha = 0.6
        girlsButton.isEnabled = false
        anyButton.isEnabled = false
    }
    
    @IBAction func tapOnGuys(_ sender: Any) {
        guysView.alpha = 1.0
        girlsButton.isEnabled = true
        anyButton.isEnabled = true
        DatingKit.user.set(lookingFor: .guys) { (status) in
            switch status {
            case .succses:
                self.performSegue(withIdentifier: "second", sender: nil)
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
//        User.shared.set(lookingFor: .man) {
//            self.performSegue(withIdentifier: "second", sender: nil)
//        }
    }
    
    @IBAction func endTapOnGuys(_ sender: Any) {
        guysView.alpha = 1.0
        girlsButton.isEnabled = true
        anyButton.isEnabled = true
    }
    
    @IBAction func startTapOnGirls(_ sender: Any) {
        girlsView.alpha = 0.6
        guysButton.isEnabled = false
        anyButton.isEnabled = false
    }
    
    @IBAction func tapOnGirls(_ sender: Any) {
        girlsView.alpha = 1.0
        guysButton.isEnabled = true
        anyButton.isEnabled = true
        DatingKit.user.set(lookingFor: .girls) { (status) in
            switch status {
            case .succses:
                self.performSegue(withIdentifier: "second", sender: nil)
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
//        User.shared.set(lookingFor: .woman) {
//            self.performSegue(withIdentifier: "second", sender: nil)
//        }
    }
    
    @IBAction func endTapOnGirls(_ sender: Any) {
        girlsView.alpha = 1.0
        guysButton.isEnabled = true
        anyButton.isEnabled = true
    }
    
    @IBAction func startTapOnAny(_ sender: Any) {
        guysAndGirls.alpha = 0.6
        guysButton.isEnabled = false
        girlsButton.isEnabled = false
    }

    @IBAction func tapOnAny(_ sender: Any) {
        guysAndGirls.alpha = 1.0
        guysButton.isEnabled = true
        girlsButton.isEnabled = true
        DatingKit.user.set(lookingFor: .any) { (status) in
            switch status {
            case .succses:
                self.performSegue(withIdentifier: "second", sender: nil)
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

    }
    
    @IBAction func endTapOnAny(_ sender: Any) {
        guysAndGirls.alpha = 1.0
        guysButton.isEnabled = true
        girlsButton.isEnabled = true
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
