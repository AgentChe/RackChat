//
//  SetAgeAndCityViewController.swift
//  RACK
//
//  Created by Alexey Prazhenik on 2/11/20.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import Foundation
import DatingKit
import Amplitude_iOS
import NotificationBannerSwift

class SetAgeAndCityViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var invalidAgeLabel: UILabel!
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var invalidCityLabel: UILabel!
    
    private var age: Int?
    private var city: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenManager.shared.onScreenController = self

        ageTextField.delegate = self
        ageTextField.setLeftPaddingPoints(12)
        
        cityTextField.delegate = self
        cityTextField.setLeftPaddingPoints(12)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapToHideKeyboard))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
        
        activityIndicator.isHidden = true
        
        continueButton(disable: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Amplitude.instance()?.log(event: .ageAndCityScr)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ageTextField.isHidden = false
        cityTextField.isHidden = false
        continueButton.isHidden = false
        activityIndicator.isHidden = true
    }
    
    private func continueButton(disable: Bool) {
        continueButton.isEnabled = !disable
        continueButton.alpha = disable ? 0.5 : 1.0
    }
        
    @objc func tapToHideKeyboard() {
        ageTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func checkContinueButton() {
        continueButton(disable: invalidAgeLabel.isHidden && invalidCityLabel.isHidden)
    }
    
    func checkFieldsAndContinue() {
        
        guard let ageText = ageTextField.text, let age = Int(ageText) else {
            showAge(invalid: true)
            return
        }
        
        guard age >= 18 else {
            self.performSegue(withIdentifier: "toYong", sender: nil)
            return 
        }

        
//        Amplitude.instance()?.log(event: .emailTap)
        tapToHideKeyboard()
        
//        if self.email!.last == " " {
//            email?.removeLast()
//        }
//        if isValid(email: self.email!) {
//            continueButton.isHidden = true
//            activityIndicator.isHidden = false
//            activityIndicator.startAnimating()
//
//            DatingKit.user.create(email: self.email!) { (new, status) in
//                switch status {
//                case .succses:
//                    if new {
//                        CurrentAppConfig.shared.setVersion()
//                        CurrentAppConfig.shared.setLocale()
//                        self.performSegue(withIdentifier: "test", sender: nil)
//                    } else {
//                        self.performSegue(withIdentifier: "code", sender: nil)
//                    }
//                    break
//                case .banned:
//                    self.continueButton.isHidden = false
//                    self.activityIndicator.isHidden = true
//                    self.activityIndicator.stopAnimating()
//                    self.performSegue(withIdentifier: "banned", sender: nil)
//                    break
//                case .noInternetConnection:
//                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
//                    self.continueButton.isHidden = false
//                    self.activityIndicator.isHidden = true
//                    self.activityIndicator.stopAnimating()
//                    banner.show(on: self.navigationController)
//                    break
//                default:
//                    self.continueButton.isHidden = false
//                    self.activityIndicator.isHidden = true
//                    self.activityIndicator.stopAnimating()
//                    let alertController = UIAlertController(title: "ERROR", message: "Can't Create account", preferredStyle: .alert)
//                    let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
//                    alertController.addAction(action)
//                    self.present(alertController, animated: true, completion: nil)
//                    break
//                }
//            }
//
//        } else {
//            Amplitude.instance()?.log(event: .emailError)
//            showEmail(invalid: true)
//        }
    }

    func showAge(invalid: Bool) {
        ageTextField.layer.borderWidth = invalid ? 1.0 : 0.0
        invalidAgeLabel.isHidden = !invalid
        checkContinueButton()
    }

    func showCity(invalid: Bool) {
        cityTextField.layer.borderWidth = invalid ? 1.0 : 0.0
        invalidCityLabel.isHidden = !invalid
        checkContinueButton()
    }
    
    @IBAction func tapOnContinue(_ sender: UIButton) {
        checkFieldsAndContinue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "code" {
//            if let codeVC: CodeViewController = segue.destination as? CodeViewController {
//                codeVC.email = self.email!
//            }
//        }
    }
    
}

extension SetAgeAndCityViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var email = textField.text! + string
        if string == "" {
            email.removeLast()
        }
        
        if email != "" {
            continueButton(disable: false)
        }  else {
            continueButton(disable: true)
        }
        
//        if isValid(email: email) {
//            showEmail(invalid: false)
//        }
//        self.email = email
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        checkEmailAndContinue()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == ageTextField {
//            self.age = textField.text
        } else if textField == cityTextField {
//            self.city = textField.text
        }
    }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension SetAgeAndCityViewController {
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100.0
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        navigationController?.isNavigationBarHidden = false
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }

}
