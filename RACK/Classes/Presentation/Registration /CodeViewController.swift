//
//  CodeViewController.swift
//  RACK
//
//  Created by Алексей Петров on 29/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit
import Amplitude_iOS
import NotificationBannerSwift

class CodeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var sendNewCodeSpacing: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var textFields: [UITextField]!
//    @IBOutlet var images: [UIImageView]!
    
    
    private var code: String!
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ScreenManager.shared.onScreenController = self
        weak var weakSelf = self
        textFields.forEach { (textField) in
            textField.delegate = weakSelf
        }
        
        DatingKit.user.generateValidationCode(email: self.email) { (status) in
            if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self.navigationController)
            }
        }
        textFields.first?.becomeFirstResponder()
        code = ""
        messageLabel.text  = "We’ve just sent to \n" + email
        textFields.forEach { (textField) in
//            textField.setLeftPaddingPoints(12)
        }
//        let str = User.shared.userData?.email
//        messageLabel.text = NSLocalizedString("send_message", comment: "") + str!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Amplitude.instance()?.log(event: .codeScr)
    }
    
    @IBAction func tapOnSendNewCode(_ sender: UIButton) {
         Amplitude.instance()?.log(event: .codeTap)
//        User.shared.generateCode()
    }
    
    func hideActivity() {
        sendNewCodeSpacing.constant = 37
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.activityView.isHidden = true
            self.activityIndicator.alpha = 0.0
            self.textFields.first?.becomeFirstResponder()
        }
    }
    
    func showActivity() {
        self.view.endEditing(true)
        sendNewCodeSpacing.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.activityView.isHidden = false
            self.activityIndicator.alpha = 1.0
        }) { (succses) in
            if self.email == "" {
                return
            }
            DatingKit.user.verify(code: self.code, email: self.email) { (new, status) in
                switch status {
                case .succses:
                    CurrentAppConfig.shared.setLocale()
                    CurrentAppConfig.shared.setVersion()
                    self.view.endEditing(true)
                    Amplitude.instance()?.log(event: .codeSucces)
                    self.hideActivity()
                    self.performSegue(withIdentifier: "hello", sender: nil)
                    break
                case .banned:
                    self.performSegue(withIdentifier: "banned", sender: nil)
                    break
                case .noInternetConnection:
                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                    banner.show(on: self.navigationController)
                    break
                default:
                    Amplitude.instance()?.log(event: .codeError)
                    self.hideActivity()
                    self.code = ""
                    self.errorLabel.isHidden = false
                    break
                    
                }
            }
            
//            User.shared.verify(code: self.code, completion: { (valid, new) in
//                if valid {
////                    self.view.endEditing(true)
//
//
////                    User.shared.loadUser()
//                    CurrentAppConfig.shared.setVersion()
//                    User.shared.checkUser({ (banned) in
//                        if banned {
//
//                        } else {
//
//                        }
//                    })
//
////                    ScreenManager.shared.showMian()
//                } else {
//                    Amplitude.instance()?.log(event: .codeError)
//                    self.hideActivity()
//                    self.code = ""
//                    self.errorLabel.isHidden = false
//                }
//            })
        }
    }
    
    func confirm(_ code: String) {
        
        showActivity()
    }
    
    @objc func tapToHideKeyboard() {
        view.endEditing(true)
    }
    
    
}

extension CodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textFields.first {
            code = ""
            textField.text = ""
            _ = textFields.map{$0.text = ""}
        }
        _ = textFields.map{$0.textColor = .black}
        errorLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string != "" {
//            let index = textFields.index(where: {$0 == textField})
            code = code + string
            
            
            if textField.text == "" {
                
                textField.text = string
                return false
            } else {
                textFields.forEach { (fild) in
                    if fild == textField {
                        let nextFild = textFields.next(item: fild)
                        nextFild!.becomeFirstResponder()
                        nextFild!.text = string
                        
                        if (nextFild == textFields.first) {
                            if code.first != string.first {
                                code = string
                            }
                        }
                        if (nextFild == textFields.last) {
                            confirm(code)
                        }
                        
                    }
                }
                return false
            }
        } else {
            textFields.first?.becomeFirstResponder()
            var increment = 0
            textFields.forEach { (fild) in
                fild.text = ""
//                images[increment].isHidden = false
                increment = increment + 1
            }
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if ((textField.text?.count)! > 0) {
            textFields.forEach { (fild) in
                fild.text = ""
            }
            code = ""
//            images.forEach { (image) in
//                image.isHidden = false
//            }
            textFields.first?.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        self.returnButtonPressed(view: weakSelf!, string: text!)
        return true
    }
}

