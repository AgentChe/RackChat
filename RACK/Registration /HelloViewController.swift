//
//  HelloViewController.swift
//  RACK
//
//  Created by Алексей Петров on 27/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import NotificationBannerSwift
import Amplitude_iOS

class HelloViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var continueButton: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatingKit.user.show { (user, status) in
            switch status {
            case .succses:
                Amplitude.instance()?.setUserId("\(user?.id)")
                self.userImageView.downloaded(from: user!.avatarURL) {
                    let name = "Hi, " + user!.name
                    self.userNameLabel.text = name.uppercased()
                }
                break
            case .noInternetConnection:
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self.navigationController)
                break
            default:
                break
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.9) {
            self.continueButton.alpha = 1.0
        }
        
    }
    
    @IBAction func tapOnContinue(_ sender: Any) {
        if CurrentAppConfig.shared.showUponRegistration {
            performSegue(withIdentifier: "paygate", sender: nil)
        } else {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            if isRegisteredForRemoteNotifications {
                NotificationManager.shared.reciveNotify()
                ScreenManager.shared.showMian()
            } else {
                self.performSegue(withIdentifier: "notify", sender: nil)
            }
        }
       
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
