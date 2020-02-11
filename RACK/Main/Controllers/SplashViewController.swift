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

    // MARK: - Outlets

    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    // MARK: - VC initialization

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startAppearanceAnimation{ [weak self] in
            self?.configureApp()
        }
    }
        
    private func configureApp() {
        CurrentAppConfig.shared.configure { [weak self] (status) in
            switch status {
                
            case .succses:
                self?.setLocale()
                self?.setAppVersion()

            case .noInternetConnection:
                self?.showConnectionError()
                
            default:
                break
            }
        }
    }
        
    private func setLocale() {
        CurrentAppConfig.shared.setLocale()
    }
    
    private func setAppVersion() {
        CurrentAppConfig.shared.setVersion { [weak self] (status) in
            switch status {
                
            case .succses:
                self?.checkPaymentStatus()
                
            case .noInternetConnection:
                self?.showConnectionError()
                
            default:
                self?.resetUserData()
            }
        }
    }

    private func showConnectionError() {
        let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
        banner.show(on: self)
    }

    private func checkPaymentStatus() {
        DatingKit.user.check { (status) in
            if status == .banned {
                self.performSegue(withIdentifier: "banned", sender: nil)
            } else {
                ScreenManager.shared.startManagment()
            }
        }
    }
    
    private func resetUserData() {
        DatingKit.deleteCache()
        ScreenManager.shared.showRegistration()
    }

}

extension SplashViewController {

    static let appearanceAnimationDurationStep1 = 1.5
    static let appearanceAnimationDurationStep2 = 0.5

    private func startAppearanceAnimation(completion: @escaping ()->() ) {
        startAppearanceAnimationStep1 { [weak self] in
            self?.startAppearanceAnimationStep2 {
                completion()
            }
        }
    }
    
    private func startAppearanceAnimationStep1(completion: @escaping ()->() ) {
        let duration = SplashViewController.appearanceAnimationDurationStep1
        
        UIView.animate(withDuration: duration, animations: {
            self.activityView.isHidden = false
        }) { (sucses) in
            completion()
        }
    }
    
    private func startAppearanceAnimationStep2(completion: @escaping ()->() ) {
        let duration = SplashViewController.appearanceAnimationDurationStep2
        
        UIView.animate(withDuration: duration, animations: {
            self.activity.alpha = 1.0
        }) { (succses) in
            completion()
        }
    }

}
