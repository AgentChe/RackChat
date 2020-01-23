//
//  EmailViewController.swift
//  RACK
//
//  Created by Алексей Петров on 29/06/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//
import UIKit
import Foundation
import DatingKit
import Amplitude_iOS
import NotificationBannerSwift


class EmailViewController: UIViewController, UIGestureRecognizerDelegate {
    
//    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    private var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ScreenManager.shared.onScreenController = self
        textField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapToHideKeyboard))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
        activityIndicator.isHidden = true
        
        textField.setLeftPaddingPoints(12)
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
        Amplitude.instance()?.log(event: .emailScr)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        textField.isHidden = false
        continueButton.isHidden = false
        activityIndicator.isHidden = true
    }
    
    private func continueButton(disable: Bool) {
        continueButton.isEnabled = !disable
        continueButton.alpha = disable ? 0.5 : 1.0
    }
    
    
    private func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    @objc func tapToHideKeyboard() {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func checkEmailAndContinue() {
        Amplitude.instance()?.log(event: .emailTap)
        tapToHideKeyboard()
        if self.email!.last == " " {
            email?.removeLast()
        }
        if isValid(email: self.email!) {
            continueButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            DatingKit.user.create(email: self.email!) { (new, status) in
                switch status {
                case .succses:
                    if new {
                        CurrentAppConfig.shared.setVersion()
                        CurrentAppConfig.shared.setLocale()
                        self.performSegue(withIdentifier: "test", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "code", sender: nil)
                    }
                    break
                case .banned:
                    self.continueButton.isHidden = false
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "banned", sender: nil)
                    break
                case .noInternetConnection:
                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                    self.continueButton.isHidden = false
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    banner.show(on: self.navigationController)
                    break
                default:
                    self.continueButton.isHidden = false
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    let alertController = UIAlertController(title: "ERROR", message: "Can't Create account", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                    break
                }
            }
            
        } else {
            Amplitude.instance()?.log(event: .emailError)
            showEmail(invalid: true)
        }
    }
    
    func showEmail(invalid: Bool) {
        textField.layer.borderWidth = invalid ? 1.0 : 0.0
        invalidEmailLabel.isHidden = !invalid
        continueButton(disable: invalid)
    }
    
    @IBAction func tapOnContinue(_ sender: UIButton) {
        checkEmailAndContinue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "code" {
            if let codeVC: CodeViewController = segue.destination as? CodeViewController {
                codeVC.email = self.email!
            }
        }
    }
    
}

extension EmailViewController: UITextFieldDelegate {
    
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
        
        if isValid(email: email) {
            showEmail(invalid: false)
        }
        self.email = email
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkEmailAndContinue()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.email = textField.text
    }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
