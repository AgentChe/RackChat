//
//  SplashViewController.swift
//  RACK
//
//  Created by Алексей Петров on 28/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import NotificationBannerSwift

class SplashViewController: UIViewController {

    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func setVersion() {
        CurrentAppConfig.shared.setVersion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.5, animations: {
            self.activityView.isHidden = false
        }) { (sucses) in
            UIView.animate(withDuration: 0.5, animations: {
                self.activity.alpha = 1.0
            }) { (succses) in
                CurrentAppConfig.shared.configure { (status) in
                    switch status {
                        
                    case .succses:
                        CurrentAppConfig.shared.setLocale()
                        CurrentAppConfig.shared.setVersion { (status) in
                            switch status {

                            case .succses:
                                DatingKit.user.check { (status) in
                                    if status == .banned {
                                        self.performSegue(withIdentifier: "banned", sender: nil)
                                    } else {
                                        ScreenManager.shared.startManagment()
                                    }
                                }
                                break
                            case .noInternetConnection:
                                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                                banner.show(on: self)
                                break
                            default:
                                DatingKit.deleteCache()
                                ScreenManager.shared.showRegistration()
                                break
                            }
                        }
                        break
                    case .noInternetConnection:
                        let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                        banner.show(on: self)
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
    }
}
