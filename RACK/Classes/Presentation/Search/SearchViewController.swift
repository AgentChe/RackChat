//
//  SearchViewController.swift
//  RACK
//
//  Created by Алексей Петров on 13/07/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import NotificationBannerSwift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchSubtitle: UILabel!
    @IBOutlet weak var noMessageLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var timeoutView: UIView!
    @IBOutlet weak var noOneView: UIView!
    @IBOutlet weak var newSearchView: UIView!
    @IBOutlet weak var subtitleView: UIView!
    @IBOutlet weak var searchTextLabel: UILabel!
    @IBOutlet weak var spaceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var upViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userPicCentring: NSLayoutConstraint!
    @IBOutlet weak var myMatchAvatarImageView: UIImageView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var sureButtonView: SureButtonView!
    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var skipButtonView: SkipButtonView!
    @IBOutlet weak var partnerImageLeading: NSLayoutConstraint!
    @IBOutlet weak var partnerAvatar: UIImageView!
    @IBOutlet weak var heightButtonView: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GardientView!
    @IBOutlet weak var searchViewWidth: NSLayoutConstraint!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var nameBundle: UIStackView!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var noOneWithRequest: UIView!
    
    private var searchTimer: Timer = Timer()
    private var paygateIsOnScreen: Bool = false
    private var userDefaults: UserDefaults = UserDefaults.standard
    private var wasShow: Bool = false
    var startFromChatView: Bool = false
    private var isMatchState = false
    
    var currentMatch: DKMatch = DKMatch()
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    weak var delegate: SearchViewDelegate?
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lookingView: UIStackView!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         Amplitude.instance()?.log(event: .searchScr)
        if lookingView.alpha == 0.0 {
            activity.isHidden = false
            UIView.animate(withDuration: 0.8) {
                self.activity.alpha = 1.0
            }
            
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPaygate), name: PaymentManager.needPayment, object: nil)
        
        if startFromChatView {
            startFromChatView = false
            if isMatchState == false {
                startSearching()
            }
            
            
        }
    }
    
    
        func found(match: DKMatch) {
            lookingView.isHidden = false
            replyView.isHidden = true
            isMatchState = true
            currentMatch = match
            
            let gender: String = "SHE"
            noMessageLabel.text = "SORRY," + gender + " SAID NO"
            partnerAvatar.downloaded(from: match.matchedUserAvatarTransparent) {
                self.partnerAvatar.isHidden = false
                
                self.searchViewWidth.constant = 0
    //            self.searchViewHeight.constant = 0
                self.heightButtonView.constant = 190
                self.gradientView.startColor = UIColor.hexStringToUIColor(hex: match.gradient.gradientStartColor)
                self.gradientView.endColor = UIColor.hexStringToUIColor(hex: match.gradient.gradientEndColor)
                let fullName: String = match.matchedUserName.uppercased()
                let split = fullName.split(separator: " ")
                let last = String(split.suffix(1).joined(separator: [" "]))
                self.secondNameLabel.text = " " + last + "?" + " "
                self.firstNameLabel.text = " " + fullName.components(separatedBy: " ").dropLast().joined(separator: " ") + " "
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                    self.lookingView.alpha = 0.0
                    self.gradientView.alpha = 1.0
                    self.nameBundle.alpha = 1.0
                }) { (succses) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.partnerAvatar.alpha = 1.0
                        self.myMatchAvatarImageView.alpha = 1.0
                    }, completion: { (succses) in
                        self.userPicCentring.constant = 75
                        self.partnerImageLeading.constant = -40
                        UIView.animate(withDuration: 25, animations: {
                            self.view.layoutIfNeeded()
                        })
            
                    })
                }
            }

            
        }
    
    func startSearching() {
        self.searchView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.searchView.alpha = 1.0
        }
        self.partnerImageLeading.constant = -80
               self.userPicCentring.constant = 150
               self.searchViewWidth.constant = 304
               self.heightButtonView.constant = 0
        DatingKit.user.show { (user, status) in
            if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self)
                return
            }
            
            DatingKit.search.startSearch(email: user!.email) { (match, operationStatus) in
                switch operationStatus {
                    
                case .none:
                    break
                case .succses:
                    self.found(match: match)
                case .noInternetConnection, .badGateway:
                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                    banner.show(on: self)
                case .needPayment:
                    self.showPaygate()
                case .timeOut:
                    let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                    if isRegisteredForRemoteNotifications {
                        self.noOneView.isHidden = false
                                            
                        UIView.animate(withDuration: 0.4, animations: {
                            self.noOneView.alpha = 1.0
                            self.searchView.alpha = 0.0
                        }) { (fin) in
                            self.searchView.isHidden = true
                        }
                    } else {
                        
                        self.noOneWithRequest.isHidden = false
                                            
                        UIView.animate(withDuration: 0.4, animations: {
                            self.noOneWithRequest.alpha = 1.0
                            self.searchView.alpha = 0.0
                        }) { (fin) in
                            self.searchView.isHidden = true
                        }
//                        _ = 0
                    }
                    
                    
                default:
                    break
                }
            }
            
        }
    }
    
    func setText(user: UserShow) {

        let lookingForStr: String = user.lookingFor == .guys ? "guys" : "girls"
        searchSubtitle.text =  "Push the button to match with " + lookingForStr + " who are into the same stuff as you."
        
    }
    
    @objc func handlePush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
       
        
        if !startFromChatView {
            searchTextLabel.text = "ready for new encounters?".uppercased()
            subtitleView.isHidden = false
            newSearchView.isHidden = false
        }
        
        if userDefaults.bool(forKey: "first_start") == false {
            UserDefaults.standard.set(true, forKey: "first_start")
            upViewHeight.constant = -30
            spaceViewHeight.constant = -60
        }
       
        replyView.alpha = 0.0
        replyView.isHidden = true
        nameBundle.alpha = 0.0
        self.partnerAvatar.alpha = 0.0
        self.myMatchAvatarImageView.alpha = 0.0
        heightButtonView.constant = 0
        self.partnerImageLeading.constant = -80
        DatingKit.user.show { (user, status) in
            if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self)
                return
            }

            if user != nil {
                self.setText(user: user!)
                self.myMatchAvatarImageView.downloaded(from: user!.matchingAvatarURL, complation: {
                    self.userImageView.downloaded(from: user!.avatarURL) {
                        self.activity.isHidden = true
                                               self.upViewHeight.constant = 60.0
                                               self.spaceViewHeight.constant = 30.0
                                               UIView.animate(withDuration: 1.2, animations: {
                                                   self.view.layoutIfNeeded()
                                                   self.lookingView.alpha = 1.0
                                               })
                    }
                   
                       
                })
                
            }
            
        }
        
    }
    
    @objc func showPaygate() {
        performSegue(withIdentifier: "paygate", sender: nil)
    }
    
    @IBAction func tapOnRequestNotify(_ sender: Any) {
        
        let alertController = UIAlertController (title: "Enable Push Notification", message: "Go to Settings?", preferredStyle: .alert)

           let settingsAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                   return
               }

               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                      self.noOneView.isHidden = false
                             UIView.animate(withDuration: 0.4, animations: {
                                 self.noOneView.alpha = 1.0
                                 self.noOneWithRequest.alpha = 0.0
                             }) { (fin) in
                                 self.noOneWithRequest.isHidden = true
                             }
                   })
               }
           }
           alertController.addAction(settingsAction)
           let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
           alertController.addAction(cancelAction)

           present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func tapOnSearch(_ sender: Any) {
        UIView.animate(withDuration: 0.8, animations: {
            self.subtitleView.alpha = 0.0
            self.newSearchView.alpha = 0.0
        }) { (fin) in
            
            UIView.animate(withDuration: 0.3, animations: {
                self.subtitleView.isHidden = true
                self.newSearchView.isHidden = true
                self.searchTextLabel.alpha = 0.0
            }, completion: { (fin) in
                self.searchTextLabel.text = "Hold Tight, Looking for Some Action...".uppercased()
               
                UIView.animate(withDuration: 0.3, animations: {
                    self.searchTextLabel.alpha = 1.0
                    self.startSearching()
                })
            })
            
        }
    }
    
    @IBAction func tapOnBack(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
//            self!.delegate?.wasDismis(searchView: self!)
        }
    }
    
    @IBAction func tapOnNewSearch(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
//        SearchManager.shared.sayNo(for: currentMatch.data!.match!)
        self.partnerImageLeading.constant = -80
        self.userPicCentring.constant = 150
        self.searchViewWidth.constant = 304
//        self.searchViewHeight.constant = 338.5
        self.heightButtonView.constant = 0
        self.searchView.isHidden = false
        self.replyView.isHidden = true
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.noView.alpha = 0.0
            self.searchView.alpha = 1.0
            self.lookingView.alpha = 1.0
            self.gradientView.alpha = 0.0
            self.nameBundle.alpha = 0.0
            self.partnerAvatar.alpha = 0.0
            self.myMatchAvatarImageView.alpha = 0.0
        }) { (fin) in
            self.partnerAvatar.isHidden = true
            self.noView.isHidden = true
            self.startSearching()
        }
    }
    
    @IBAction func endTapOnSure(_ sender: Any) {
        sureButtonView.alpha = 1.0
        skipButton.isEnabled = true
    }
    
    @IBAction func tapOnSure(_ sender: Any) {
      
        DatingKit.search.sayYes(matchID: currentMatch.matchID) { (matchStatus, status) in
            switch status {
            case .succses:
                
                switch matchStatus {
                
                case .waitPartnerAnser:
                    self.sureButtonView.alpha = 1.0
                    self.skipButton.isEnabled = true
                    self.sureButtonView.alpha = 1.0
                          self.skipButton.isEnabled = true
                          self.replyView.isHidden = false
                          self.partnerImageLeading.constant = 0
                          UIView.animate(withDuration: 2) {
                              self.view.layoutIfNeeded()
                              self.nameBundle.alpha = 0.0
                              self.replyView.alpha = 1.0
                              UIView.animate(withDuration: 0.3) {
                                  self.myMatchAvatarImageView.alpha = 0.0
                              }
                          }
                    break
                case .timeOut:
                    self.isMatchState = false
                    self.gradientView.startColor = .white
                    self.gradientView.endColor = .white
                    self.skipButtonView.alpha = 1.0
                    self.sureButton.isEnabled = true
                    self.searchViewWidth.constant = 304
                    self.heightButtonView.constant = 0
                    self.timeoutView.isHidden = false
                    UIView.animate(withDuration: 0.4, animations: {
                        self.view.layoutIfNeeded()
                        self.gradientView.alpha = 0.0
                        self.nameBundle.alpha = 0.0
                        self.partnerAvatar.alpha = 0.0
                        self.myMatchAvatarImageView.alpha = 0.0
                    }) { (fin) in
                        self.partnerAvatar.isHidden = true
                        self.searchView.isHidden = true
                        UIView.animate(withDuration: 0.4, animations: {
                            self.timeoutView.alpha = 1.0
                        })
                    }
                case .deny:
                    
                    self.isMatchState = false
                    self.noView.isHidden = false
                    UIView.animate(withDuration: 0.4, animations: {
                        self.noView.alpha = 1.0
                        self.partnerAvatar.alpha = 0.0
                        self.searchView.alpha = 0.0
                    }) { (fin) in
                        self.partnerAvatar.isHidden = true
                        self.searchView.isHidden = true
                        self.startSearching()
                    }
                case .confirmPending:
                    self.dismiss(animated: true) {
                        self.delegate?.tapOnYes()
                    }
                case .lostChat:
                    break
                case .report:
                    break
                case .cantAnswer:
                    break
                }
                
            case .noInternetConnection:
                switch matchStatus {
                case .cantAnswer:
                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                    banner.show(on: self)
                    break
                    
                case .waitPartnerAnser:
                    let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                    banner.show(on: self)
                    break
                                       
                default: break
                }
            case .needPayment:
                self.showPaygate()
                break
            default:
                break
            }
        }
    }
    
    @IBAction func TapOnNewSearchAfterTimeout(_ sender: Any) {
        isMatchState = false
        gradientView.startColor = .white
        gradientView.endColor = .white
        self.searchViewWidth.constant = 304
        self.heightButtonView.constant = 0
        searchView.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.searchView.alpha = 1.0
                        self.lookingView.alpha = 1.0
            self.timeoutView.alpha = 0.0
            self.gradientView.alpha = 0.0
            self.nameBundle.alpha = 0.0
            self.partnerAvatar.alpha = 0.0
            self.myMatchAvatarImageView.alpha = 0.0
        }) { (fin) in
            self.startSearching()
            self.partnerAvatar.isHidden = true
        }
    }
    
    @IBAction func startTapOnSure(_ sender: Any) {
        sureButtonView.alpha = 0.6
        skipButton.isEnabled = false
        
    }
    
    @IBAction func tapOnSkipSearch(_ sender: Any) {
        self.dismiss(animated: true) {
//            self.delegate?.wasDismis(searchView: self)
        }
    }
    
    @IBAction func tapOnSureSearch(_ sender: Any) {
        searchView.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.noOneView.alpha = 0.0
            self.searchView.alpha = 1.0
        }) { (fin) in
            self.startSearching()
        }
    }
    
    @IBAction func endTapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
    }
    
    @IBAction func startTapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 0.6
        sureButton.isEnabled = false
        
    }
    
    @IBAction func tapOnSkipOnNoOneWithRequest(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.noOneWithRequest.alpha = 0.0
        }) { (fin) in
            self.noOneWithRequest.isHidden = true
            self.startSearching()
        }
       
    }
    
    @IBAction func tapOnSkip(_ sender: Any) {
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
        DatingKit.search.sayNo(matchID: currentMatch.matchID) { (status) in
            if status == .noInternetConnection {
                let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
                banner.show(on: self)
                return
            }
            
            if status == .needPayment {
                self.showPaygate()
                return
            }
            
            if status == .succses {
                self.searchViewWidth.constant = 304
                self.heightButtonView.constant = 0
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.view.layoutIfNeeded()
                    self.lookingView.alpha = 1.0
                    self.gradientView.alpha = 0.0
                    self.nameBundle.alpha = 0.0
                    self.partnerAvatar.alpha = 0.0
                    self.myMatchAvatarImageView.alpha = 0.0
                }) { (fin) in
                    self.partnerAvatar.isHidden = true
                    self.startSearching()
                }
            }
            
        }

    }
    
    
    func shadow(show: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.shadowView.alpha = show ? 1.0 : 0.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shadow(show: true)

    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatingKit.search.stopAll()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        delegate?.wasDismis(searchView: self)
        super.dismiss(animated: flag, completion: completion)
    }
    
    func showPartner() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "paygate" {
            let paygate: PaymentViewController = segue.destination as! PaymentViewController
            paygate.delegate = self
//            let config: ConfigBundle = sender as! ConfigBundle
//            paygate.config(bundle: config)
        }
    }

    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        shadow(show: false)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 200 {
//                self.dismiss(animated: true) {
//                    self.delegate?.wasDismis(searchView: self)
//                }
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    self.shadow(show: true)
                })
            }
        }
    }

}

extension SearchViewController: PaymentViewControllerDelegate {
    
    func wasPurchased() {
        
    }
    
    func wasClosed() {
        UserDefaults.standard.set(true, forKey: "first_start")
        if isMatchState == false {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchTextLabel.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.searchTextLabel.alpha = 1.0
            })
            self.subtitleView.isHidden = false
            self.newSearchView.isHidden = false
            
        }) { (fin) in
            
            UIView.animate(withDuration: 0.3, animations: {
                self.subtitleView.alpha = 1.0
                self.newSearchView.alpha = 1.0
                
            }, completion: { (fin) in
                self.searchTextLabel.text = "ready for new encounters?".uppercased()
                
               
            })
            
        }
        }
    }
}


extension SearchViewController: SearchManagerProtocol {
    
    func answerRequestFailed() {
        self.partnerImageLeading.constant = -80
        self.userPicCentring.constant = 150
        self.searchViewWidth.constant = 304
    }
    
    func answerRequestSuccses() {
       
    }
    
    
    func foundet(match: Match) {

        
    }
    
    func startSearch() {
       
    }
    
    func searchWasStoppet() {
      searchTimer.invalidate()
    }
    
    func answer(partner: CheckMatch) {
        if partner.status == .confirmPending {
            dismiss(animated: true) {
                self.delegate?.tapOnYes()
            }
        } else {
            isMatchState = false
            noView.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.noView.alpha = 1.0
                self.searchView.alpha = 0.0
            }) { (fin) in
                self.searchView.isHidden = true
            }
        }
    }
    
    func matchWasDeny() {
        isMatchState = false
        gradientView.startColor = .white
        gradientView.endColor = .white
        skipButtonView.alpha = 1.0
        sureButton.isEnabled = true
        self.searchViewWidth.constant = 304
        self.heightButtonView.constant = 0
        timeoutView.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
//            self.lookingView.alpha = 1.0
            self.gradientView.alpha = 0.0
            self.nameBundle.alpha = 0.0
            self.partnerAvatar.alpha = 0.0
            self.myMatchAvatarImageView.alpha = 0.0
        }) { (fin) in
            self.partnerAvatar.isHidden = true
            self.searchView.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.timeoutView.alpha = 1.0
            })
        }
        
    }
}


extension SearchViewController: NotificationDelegate {
    func notificationRequestWasEnd(succses: Bool) {
        
        if succses == false {
            return
        }
        

    }
    
    
}
