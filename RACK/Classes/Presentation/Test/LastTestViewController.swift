//
//  LastTestViewController.swift
//  RACK
//
//  Created by Алексей Петров on 26/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import NotificationBannerSwift


class LastTestViewController: UIViewController {

    @IBOutlet weak var imagingButton: UIButton!
    @IBOutlet weak var textingButton: UIButton!
    @IBOutlet weak var textingView: UIView!
    @IBOutlet weak var imageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amplitude.instance()?.log(event: .thriedOnboardingScr)
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.triedTest, forKey: ScreenManager.currentScreen)
    }
    
    @IBAction func startTapOnTexting(_ sender: Any) {
        textingView.alpha = 0.6
        imagingButton.isEnabled = false
    }
    
    @IBAction func tapOnTexting(_ sender: Any) {
        textingView.alpha = 1.0
        imagingButton.isEnabled = true
        DatingKit.user.set(chatType: .text) { (status) in
             switch status {
                       case .succses:
                           self.performSegue(withIdentifier: "random", sender: nil)
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
    
    @IBAction func endTapOnTexting(_ sender: Any) {
        textingView.alpha = 1.0
        imagingButton.isEnabled = true
    }
    
    @IBAction func startTapOnImaging(_ sender: Any) {
        imageView.alpha = 0.6
        textingButton.isEnabled = false
    }
    
    @IBAction func tapOnImaging(_ sender: Any) {
        imageView.alpha = 1.0
        textingButton.isEnabled = true
        DatingKit.user.set(chatType: .image) { (status) in
             switch status {
                       case .succses:
                           self.performSegue(withIdentifier: "random", sender: nil)
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
    
    @IBAction func endTapOnImaging(_ sender: Any) {
        imageView.alpha = 1.0
        textingButton.isEnabled = true
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
