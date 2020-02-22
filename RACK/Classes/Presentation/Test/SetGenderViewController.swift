//
//  SetGenderViewController.swift
//  RACK
//
//  Created by Алексей Петров on 24/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class SetGenderViewController: UIViewController {

    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var manButton: UIButton!
    
    @IBOutlet weak var manView: UIView!
    @IBOutlet weak var womanView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.gender, forKey: ScreenManager.currentScreen)
    }
    
    @IBAction func startTapOnWoman(_ sender: UIButton) {
        womanView.alpha = 0.6
        manButton.isEnabled = false
    }
    
    @IBAction func startTapOnMan(_ sender: Any) {
        manView.alpha = 0.6
        womenButton.isEnabled = false
    }
    
    @IBAction func tapOnMan(_ sender: UIButton) {
        manView.alpha = 1.0
        womenButton.isEnabled = true
        
        DatingKit.user.set(gender: .man) { (status) in
            switch status {
            case .succses:
                CurrentAppConfig.shared.setGender(gender: .man)
                self.randomizeUser()

            case . noInternetConnection:
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self.navigationController)

            default:
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)

            }
        }
//        User.shared.set(gender: .man) { [weak self] in
//            self?.performSegue(withIdentifier: "first", sender: nil)
//        }
    }
    
    @IBAction func endTapOnMan(_ sender: UIButton) {
        manView.alpha = 1.0
        womenButton.isEnabled = true
    }
    
    @IBAction func tapOnWoman(_ sender: UIButton) {
        womanView.alpha = 1.0
        manButton.isEnabled = true
        
        DatingKit.user.set(gender: .woman) { (status) in
            switch status {
            case .succses:
                CurrentAppConfig.shared.setGender(gender: .woman)
                self.randomizeUser()

            case . noInternetConnection:
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self.navigationController)

            default:
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)

            }
        }
    }
    
    @IBAction func endTapOnWoman(_ sender: Any) {
        womanView.alpha = 1.0
        manButton.isEnabled = true
    }
    
    
    private func randomizeUser() {
        DatingKit.user.show { (_, _) in
            DatingKit.user.randomize { (_, _) in
                self.performSegue(withIdentifier: "first", sender: nil)
            }
        }
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
