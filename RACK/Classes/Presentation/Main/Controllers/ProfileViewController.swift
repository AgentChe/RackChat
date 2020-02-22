//
//  ProfileViewController.swift
//  Alamofire
//
//  Created by Алексей Петров on 02/07/2019.
//

import UIKit
import NotificationBannerSwift
import AlamofireImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyActivityView: UIVisualEffectView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 25.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        DatingKit.user.show { (user, status) in
            if status == .noInternetConnection {
                self.avatarImageView.image = user?.gender == .man ? #imageLiteral(resourceName: "man") : #imageLiteral(resourceName: "woman")
                self.emailLabel.text = user?.email
                self.nameLabel.text = user?.name
            } else {
                self.emailLabel.text = user?.email
                self.nameLabel.text = user?.name
                if let avatar: UIImage = user?.avatar {
                    self.avatarImageView.image = avatar
                } else {
                    guard let avatarURL: URL =  URL(string: user!.avatarURL) else {
                        return
                    }
//                    self.avatarImageView.af_setImage(withURL: avatarURL)
                    self.avatarImageView.af_setImage(withURL: avatarURL,
                                                     placeholderImage: user?.gender == .man ? #imageLiteral(resourceName: "man") : #imageLiteral(resourceName: "woman"),
                                                     filter: nil,
                                                     progress: nil,
                                                     progressQueue: DispatchQueue.main,
                                                     imageTransition: UIImageView.ImageTransition.crossDissolve(0.2),
                                                     runImageTransitionIfCached: false,
                                                     completion: nil)
                }
            }
        }
    }

    @IBAction func tapOnMenu(_ sender: UIBarButtonItem) { 
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 
        actionSheet.addAction(UIAlertAction(title: "Delete Account...", style: .destructive, handler: { [weak self] (action) in
            self?.performSegue(withIdentifier: "delete", sender: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        present(actionSheet, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let text: String = "Check out RACK... the anonymous chat"
                if let myWebsite = NSURL(string: "https://apps.apple.com/app/rack-naughty-chat-dating/id1472868612") {
                    let objectsToShare = [text, myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
                    activityVC.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
            
            if indexPath.row == 1 {
                buyActivityView.isHidden = false
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                navigationController?.setNavigationBarHidden(true, animated: true)
                UIView.animate(withDuration: 0.5) {
                    self.buyActivityView.alpha = 1.0
                    self.activityIndicator.alpha = 1.0
                }
                PurchaseManager.shared.restore { (status) in
                    switch status {
                    case .failed:
                        let alert = UIAlertController(title: "ERROR", message: "Restore Failed", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                            UIView.animate(withDuration: 0.4, animations: {
                                self.buyActivityView.alpha = 0.0
                                self.activityIndicator.alpha = 0.0
                            }, completion: { (fin) in
                                self.buyActivityView.isHidden = true
                                self.activityIndicator.isHidden = true
                                self.navigationController?.setNavigationBarHidden(false, animated: true)
                            })
                       
                        }))
                         self.present(alert, animated: true, completion: nil)
                    case .restored:
                        let alert = UIAlertController(title: "Seccsesful Restored", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                            UIView.animate(withDuration: 0.4, animations: {
                                self.buyActivityView.alpha = 0.0
                                self.activityIndicator.alpha = 0.0
                            }, completion: { (fin) in
                                self.buyActivityView.isHidden = true
                                self.activityIndicator.isHidden = true
                                self.navigationController?.setNavigationBarHidden(false, animated: true)
                            })
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            if indexPath.row == 2 {
                guard let url = URL(string: "https://rack.today/legal/contact") else { return }
                UIApplication.shared.open(url)
            }
            
            if indexPath.row == 3 {
                if !UIApplication.shared.isRegisteredForRemoteNotifications {
                     let alertController = UIAlertController (title: "“RACK” Would Like to Send You Notifications", message: "To manage push notifications you'll need to enable them in app's settings first", preferredStyle: .alert)

                             let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

                              guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                     return
                                 }

                                 if UIApplication.shared.canOpenURL(settingsUrl) {
                                     UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                       
                                     })
                                 }
                             }
                             alertController.addAction(settingsAction)
                             let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                             alertController.addAction(cancelAction)

                             present(alertController, animated: true, completion: nil)
                }  else {
                    performSegue(withIdentifier: "notification", sender: nil)
                }
                
            }
            
        }
        
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                guard let url = URL(string: "https://rack.today/legal/policy") else { return } //https://rack.today/legal/terms
                UIApplication.shared.open(url)
            }
            
            if indexPath.row == 1 {
                guard let url = URL(string: "https://rack.today/legal/terms") else { return } //https://rack.today/legal/policy
                UIApplication.shared.open(url)
            }
            
        }
        
        
        
        //https://fawn.chat/legal/policy
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 4
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Share Rack"
            }
            if indexPath.row == 1 {
                cell.textLabel?.text = "Restore Purchases"
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.text = "Contact Us"
            }
            
            if indexPath.row == 3 {
                cell.textLabel?.text  = "Push Notifications"
            }
            
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Privacy Policy"

            }
            
            
            if indexPath.row == 1 {
                cell.textLabel?.text = "Terms of Service"
            }
        }
        
        return cell
    }
}
