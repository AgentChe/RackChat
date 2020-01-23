//
//  DeleteViewController.swift
//  RACK
//
//  Created by Алексей Петров on 30/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import NotificationBannerSwift

class DeleteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapOnDelete(_ sender: Any) {
        DatingKit.user.logout { (status) in
            if status == .succses {
                ScreenManager.shared.showRegistration()
                self.dismiss(animated: true, completion: nil)
            } else if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self)
            } else {
                let alertController = UIAlertController(title: "ERROR", message: "Something went wrong!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
//        User.shared.logout {
//
//
//            UserDefaults.standard.set(false, forKey: "first_start")
//            UserDefaults.standard.removeObject(forKey: User.lookingForKey)
//            UserDefaults.standard.removeObject(forKey: User.genderKey)
//        }
    }
    
    @IBAction func tapOnSaty(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
