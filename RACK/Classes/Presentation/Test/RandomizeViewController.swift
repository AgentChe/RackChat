//
//  RandomizeViewController.swift
//  RACK
//
//  Created by Алексей Петров on 13/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import AlamofireImage
import Amplitude_iOS
import NotificationBannerSwift

class RandomizeViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageHeght: NSLayoutConstraint!
    @IBOutlet weak var imageWight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.rand, forKey: ScreenManager.currentScreen)
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2)
        let current: UIViewController = navigationArray.last!
        navigationArray.removeAll()
        navigationArray.append(current)// To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        
        Amplitude.instance()?.log(event: .avatarScr)
        
        self.avatarImageView.image = CurrentAppConfig.shared.currentGender == .man ? #imageLiteral(resourceName: "man") : #imageLiteral(resourceName: "woman")
        
        DatingKit.user.show { (user, status) in
            switch status {
            case .succses:
                Amplitude.instance()?.setUserId("\(user?.id)")
                self.avatarImageView.downloaded(from: user!.avatarURL) {
                    self.helloLabel.text = self.helloMessage(for: user!)
                }
                break
            case .noInternetConnection:
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
    
    private func helloMessage(for user: UserShow) -> String {
        return ("HI, \(user.name.uppercased()), \(user.age) from \(user.city)")
    }
    
    func config(user: UserShow) {
        
        avatarImageView.downloaded(from: user.avatarURL) {
            self.imageWight.constant = 200
            self.imageHeght.constant = 200
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self!.view.layoutIfNeeded()
                self?.helloLabel.alpha = 1.0
                self?.subtitleLabel.alpha = 1.0
                self!.helloLabel.text = self?.helloMessage(for: user)
            })
        }
    }
    

    @IBAction func tapOnContinue(_ sender: GradientButton) {
        Amplitude.instance()?.log(event: .avatarContinueTap)
        if CurrentAppConfig.shared.showUponRegistration {
            self.performSegue(withIdentifier: "paygate", sender: nil)
        } else {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            if isRegisteredForRemoteNotifications {
                NotificationManager.shared.reciveNotify()
                UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showMain, forKey: ScreenManager.showKey)
                ScreenManager.shared.showMian()
                return
            } else {
                self.performSegue(withIdentifier: "notify", sender: nil)
            }
        }
        
    }
    
    @IBAction func tapOnRandom(_ sender: Any) {
        Amplitude.instance()?.log(event: .avatarRandTap)
        DatingKit.user.randomize { (user, status) in
            switch status {
            case .succses:
                
                self.imageWight.constant = 0
                self.imageHeght.constant = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                    self.helloLabel.alpha = 0.0
                    self.subtitleLabel.alpha = 0.0
                 }) { (succses) in
                    self.config(user: user!)
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

}


extension RandomizeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
