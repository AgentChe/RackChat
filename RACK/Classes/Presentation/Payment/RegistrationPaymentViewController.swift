//
//  RegistrationPaymentViewController.swift
//  RACK
//
//  Created by Алексей Петров on 10/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS

class RegistrationPaymentViewController: UIViewController {
    // constraits
    
    @IBOutlet weak var bundleView: UIStackView!
    @IBOutlet weak var menuBottom: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var gardientBottom: NSLayoutConstraint!
    @IBOutlet weak var imagesBottom: NSLayoutConstraint!
    
    // outlets
    @IBOutlet var reasonViews: [ReasonView]!
    @IBOutlet weak var blurActivityView: UIVisualEffectView!
    @IBOutlet weak var trialView: UIStackView!
    @IBOutlet weak var continueButton: GradientButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var rightView: RightView!
    @IBOutlet weak var centralView: CenterView!
    @IBOutlet weak var leftView: LeftView!
    @IBOutlet weak var secondBackground: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buyActivityIndicator: UIActivityIndicatorView!
    
    // trial outlets
    
    @IBOutlet weak var trialTitle: UILabel!
    @IBOutlet weak var trialButton: ButtonView!
    
    // delegate
    
    weak var delegate: PaymentViewControllerDelegate!
    
    // private
    
    private var config: ConfigBundle!
    private var showTrial: Bool = true
    private var currentID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        bundleView.alpha = 0.0
        menuBottom.constant = 400
        activityIndicator.alpha = 1.0
        
        closeButton.alpha = 0.0
        PurchaseManager.shared.loadProducts { (bundle) in
            self.setupBundleView(bundle: bundle!)
            if bundle!.isShowTrial {
                self.setupTrial(bundle: (bundle?.configTrial)!)
            }
            self.showTrial = bundle!.isShowTrial
            UIView.animate(withDuration: 0.4, animations: {
                self.activityIndicator.alpha = 0.0
                self.closeButton.alpha = 1.0
            }, completion: { (fin) in
                
                self.menuBottom.constant = 0
                UIView.animate(withDuration: 0.7, animations: {
                    self.view.layoutIfNeeded()
                    self.bundleView.alpha = 1.0
                })
            })
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Amplitude.instance()?.log(event: .paygateScr)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func nextStep() {
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            ScreenManager.shared.showMian()
            return
        } else {
            self.performSegue(withIdentifier: "notify", sender: nil)
        }
    }
    
    private func close() {
        UIView.animate(withDuration: 0.4, animations: {
            self.buyActivityIndicator.alpha = 0.0
            self.blurActivityView.alpha = 0.0
        }, completion: { (fin) in
            self.buyActivityIndicator.isHidden = true
            self.blurActivityView.isHidden = true
            if self.trialView.isHidden == false {
                self.nextStep()
            }
            
            UIView.animate(withDuration: 0.6, animations: {
                self.backgroundImage.alpha = 0.0
                if !self.showTrial {
                    self.closeButton.alpha = 0.0
                }
                self.bundleView.alpha = 0.0
                self.secondBackground.alpha = 0.0
                self.view.layoutIfNeeded()
            }) { (fin) in
                self.nextStep()
            }
        })
    }
    
    private func buy(id: String) {
        if id.count > 0 {
            blurActivityView.isHidden = false
            buyActivityIndicator.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.blurActivityView.alpha = 1.0
                self.buyActivityIndicator.alpha = 1.0
            }
            
            PurchaseManager.shared.buy(productID: id) { (status) in
                switch status {
                    
                case .succes:
                    self.close()
                case .error:
                    let alert = UIAlertController(title: "ERROR", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .unknown:
                    let alert = UIAlertController(title: "ERROR", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .clientInvalid:
                    let alert = UIAlertController(title: "ERROR", message: "Client invalid", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .paymentCancelled:
                    self.hideActivity()
                case .paymentInvalid:
                    let alert = UIAlertController(title: "ERROR", message: "Payment invalid", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .paymentNotAllowed:
                    let alert = UIAlertController(title: "ERROR", message: "Payment not allowed", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .storeProductNotAvailable:
                    let alert = UIAlertController(title: "ERROR", message: "Product not avilable", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .cloudServicePermissionDenied:
                    let alert = UIAlertController(title: "ERROR", message: "Cloud server Permishn Denaided", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .cloudServiceNetworkConnectionFailed:
                    let alert = UIAlertController(title: "ERROR", message: "Network connection failed", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .cloudServiceRevoked:
                    let alert = UIAlertController(title: "ERROR", message: "servise revoked", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                @unknown default:
                    let alert = UIAlertController(title: "ERROR", message: "Somethink went wrong", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.hideActivity()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    private func hideActivity() {
        UIView.animate(withDuration: 0.4, animations: {
            self.buyActivityIndicator.alpha = 0.0
            self.blurActivityView.alpha = 0.0
        }, completion: { (fin) in
            self.buyActivityIndicator.isHidden = true
            self.blurActivityView.isHidden = true
        })
    }
    
    private func setupTrial(bundle: ConfigTrial) {
        trialButton.config(bundle: bundle.button)
        trialTitle.text = bundle.title
        for (index, reasonView) in reasonViews.enumerated() {
            reasonView.titleLabel.text = bundle.reasons[index].title
            reasonView.subtitleLabel.text = bundle.reasons[index].subTitle
        }
    }
    
    private func setupBundleView(bundle: ConfigBundle) {
        config = bundle
        currentID = bundle.priceBundle.centralPriceTag.id
        self.countLabel.text = "\(bundle.mensCounterBundle.usersCount)"
        self.subtitleLabel.text = bundle.mensCounterBundle.usersSubstring
        self.centralView.config(with: (bundle.priceBundle.centralPriceTag))
        self.leftView.config(with: (bundle.priceBundle.leftPriceTag))
        self.rightView.config(with: (bundle.priceBundle.reightPriceTag))
        self.continueButton.titleLabel?.text = bundle.buttonBundle.name
        self.centralView.select(true)
        self.leftView.select(false)
        self.rightView.select(false)
    }
    
    @IBAction func tapOnContinue(_ sender: Any) {
        buy(id: currentID)
    }
    
    @IBAction func tapOnClose(_ sender: Any) {
        if trialView.isHidden == false {
            self.nextStep()
        }
        if  self.showTrial {
            gardientBottom.constant = 400
            imagesBottom.constant = 700
            menuBottom.constant = 400
        }
        UIView.animate(withDuration: 0.6, animations: {
            self.backgroundImage.alpha = 0.0
            if !self.showTrial {
                self.closeButton.alpha = 0.0
            }
            self.bundleView.alpha = 0.0
            self.secondBackground.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { (fin) in
            if self.showTrial {
                Amplitude.instance()?.log(event: .trialScr)
                self.trialView.isHidden = false
                UIView.animate(withDuration: 0.4, animations: {
                    self.trialView.alpha = 1.0
                })
            } else {
                self.nextStep()
            }
        }
    }

    @IBAction func tapOnPrice(_ sender: UIButton) {
        centralView.select(true)
        leftView.select(false)
        rightView.select(false)
        currentID = config.priceBundle.centralPriceTag.id
    }
    
    @IBAction func tapOnLeft(_ sender: Any) {
        centralView.select(false)
        leftView.select(true)
        rightView.select(false)
        currentID = config.priceBundle.leftPriceTag.id
    }
    
    @IBAction func tapOnRight(_ sender: Any) {
        centralView.select(false)
        leftView.select(false)
        rightView.select(true)
        currentID = config.priceBundle.reightPriceTag.id
    }
    
    @IBAction func startTapOnBuy(_ sender: Any) {
        trialButton.alpha = 0.6
    }
    
    @IBAction func tapOnBuy(_ sender: Any) {
        trialButton.alpha = 1.0
        buy(id: config.configTrial!.productID)
    }
    
    @IBAction func enTapOnBuy(_ sender: Any) {
        trialButton.alpha = 1.0
    }
    
    @IBAction func tapOnBundlePrivacy(_ sender: Any) {
        guard let url = URL(string: "https://rack.today/legal/policy") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func tapOnBundleTerms(_ sender: Any) {
        guard let url = URL(string: "https://rack.today/legal/terms") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func tapOnBundleRestore(_ sender: Any) {
        blurActivityView.isHidden = false
        buyActivityIndicator.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.blurActivityView.alpha = 1.0
            self.buyActivityIndicator.alpha = 1.0
        }
        PurchaseManager.shared.restore { (status) in
            switch status {
                
            case .restored:
                self.close()
            case .failed:
                let alert = UIAlertController(title: "ERROR", message: "Restore Failed", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    self.hideActivity()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func trialPrivacy(_ sender: Any) {
        guard let url = URL(string: "https://rack.today/legal/policy") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func trialTerms(_ sender: Any) {
        guard let url = URL(string: "https://rack.today/legal/terms") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func trialRestore(_ sender: Any) {
        blurActivityView.isHidden = false
        buyActivityIndicator.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.blurActivityView.alpha = 1.0
            self.buyActivityIndicator.alpha = 1.0
        }
        PurchaseManager.shared.restore { (status) in
            switch status {
                
            case .restored:
                self.close()
            case .failed:
                let alert = UIAlertController(title: "ERROR", message: "Restore Failed", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    self.hideActivity()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
