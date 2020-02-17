//
//  RegistrationViewController.swift
//  RACK
//
//  Created by Алексей Петров on 29/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import DatingKit
import Lottie
import Amplitude_iOS
import NotificationBannerSwift

class RegistrationViewController: UIViewController {

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var buttonsBlockHeight: NSLayoutConstraint!
    @IBOutlet weak var subnameLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var FBButton: GradientButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var neverPostLabel: UILabel!
    
    let starAnimationView: AnimationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let starAnimation = Animation.named("lf20_XZ30Ct")
        starAnimationView.animation = starAnimation
        starAnimationView.frame = CGRect(x: 0, y: -44, width: 280.0, height: 78)
       
        starAnimationView.loopMode = .loop
        starAnimationView.contentMode = .scaleAspectFit
//        starAnimationView.backgroundColor = .red
        logoView.addSubview(starAnimationView)
        
        
        starAnimationView.play { (finish) in
            
        }
//        buttonsBlockHeight.constant = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         starAnimationView.center = self.logoView.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        starAnimationView.backgroundColor = .red
        starAnimationView.frame = CGRect(x: 0, y: -44, width: 480, height: 310)
        starAnimationView.center = CGPoint(x: self.logoView.center.x, y: self.logoView.center.y - 104)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Amplitude.instance()?.log(event: .loginScr)
        starAnimationView.play { (finish) in
            
        }
    }
    
    @IBAction func tapOnEmail(_ sender: Any) {
         Amplitude.instance()?.log(event: .loginEmailTap)
    }
    
    @IBAction func tapOnFacebook(_ sender: UIButton) {
        Amplitude.instance()?.log(event: .loginFBTap)
        let manager: LoginManager = LoginManager()
        AccessToken.current = nil
        manager.logOut()
        if AccessToken.current?.tokenString == nil {
            manager.logIn(permissions: ["public_profile", "email"], from: self) { (response, error) in
                if AccessToken.current?.tokenString != nil {
                    DatingKit.user.createWithFB(token: (AccessToken.current?.tokenString)!) { [weak self] (new, status) in
                        switch status {
                        case .succses:
                            CurrentAppConfig.shared.setVersion()
                            CurrentAppConfig.shared.setLocale()
                            if new {
                                self!.performSegue(withIdentifier: "onboarding", sender: nil)
                            } else {
                                DatingKit.user.check { (status) in
                                    if status == .banned {
                                        self!.performSegue(withIdentifier: "banned", sender: nil)
                                    } else {
                                        UIView.animate(withDuration: 0.4, animations: {
                                        }, completion: { (endet) in
                                            self!.performSegue(withIdentifier: "start", sender: nil)
                                        })
                                    }
                                }
                            }

                            break
                        case .noInternetConnection:
                            let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                            banner.show(on: self?.navigationController)
                            break
                        default:
                            let alertController = UIAlertController(title: "ERROR", message: "Can't Create account", preferredStyle: .alert)
                            
                                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                                }

                                alertController.addAction(action)
                                
                                self!.present(alertController, animated: true, completion: nil)
                            break
                        }
                    }
                }
            }
        } else {
            
//            User.shared.loginFB(token: (AccessToken.current?.tokenString)!, completion: { (succses, new) in
//                if succses {
//                    if new {
//                        weakSelf?.performSegue(withIdentifier: "onboarding", sender: nil)
//                    } else {
//                        ScreenManager.shared.showSplash()
//                    }
//                    //                    weakSelf?.dismiss(animated: true, completion: nil)
//                }
//            })
        }
    }
    
    @IBAction func tapOnTerms(_ sender: Any) {
        Amplitude.instance()?.log(event: .loginTermsTap)
        guard let url = URL(string: "https://rack.today/legal/terms") else { return }
        UIApplication.shared.open(url)
        
    }
    
}
