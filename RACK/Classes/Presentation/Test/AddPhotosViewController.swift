//
//  AddPhotosViewController.swift
//  RACK
//
//  Created by Alexey Prazhenik on 2/19/20.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import Amplitude_iOS
import NotificationBannerSwift

class AddPhotoPromtView: UIStackView {
 
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var addPhotoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = titleLabel.font.properForDevice
        subtitleLabel.font = subtitleLabel.font.properForDevice
    }

}

class PhotoView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!

    var image: UIImage? {
        didSet {
            imageView.image = image
            image != nil ? removeBorder() : addBorder()
        }
    }

    private (set) var maskType: MaskType = .type1
    private var borderLayer = CAShapeLayer()
    
    typealias PhotoViewSelectionHandler = (PhotoView)->()
    var selectionHandler: PhotoViewSelectionHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
    }
    
    func configure(with mask: MaskType) {
        self.maskType = mask
        self.imageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        applyMask(maskType)
    
        removeBorder()
        addBorder()
    }

    private func removeBorder() {
        borderLayer.removeFromSuperlayer()
    }

    private func addBorder() {
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        borderLayer.lineDashPattern = [3, 5]
        borderLayer.lineWidth = 4
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = self.path(for: maskType)
        layer.addSublayer(borderLayer)
    }
    
    @objc func tapHandler() {
        guard let _ = image else { return }
        selectionHandler?(self)
    }
}

class AddPhotosViewController: UIViewController {
    
    @IBOutlet private weak var promtView: AddPhotoPromtView!
        
    @IBOutlet private weak var photosView: UIView!
    @IBOutlet private weak var photosSectionView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private var photoViews: [PhotoView] = []
    
    @IBOutlet private weak var bottomActionsView: UIView!
    @IBOutlet private weak var addMoreButton: UIButton!
    @IBOutlet private weak var continueButton: UIButton!

    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var selectedPhotos: [UIImage] {
        return photoViews.filter({ $0.image != nil }).map({ $0.image! })
    }
    
    private var isPromtVisible: Bool {
        return selectedPhotos.count == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(ScreenManager.ScreenManagerEntryTypes.showTest, forKey: ScreenManager.showKey)
        UserDefaults.standard.set(ScreenManager.ScreenManagerTestEntryScreen.addPhotos, forKey: ScreenManager.currentScreen)
        
        ScreenManager.shared.onScreenController = self
        
        titleLabel.font = titleLabel.font.properForDevice
        subtitleLabel.font = subtitleLabel.font.properForDevice
        
        photoViews[0].configure(with: .type1)
        photoViews[1].configure(with: .type2)
        photoViews[2].configure(with: .type3)
        
        photoViews.forEach { (view) in
            view.selectionHandler = { [weak self] v in
                self?.deleteAction(for: v)
            }
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    private func deleteAction(for view: PhotoView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Change Photo", style: .default, handler: { [weak self] (_) in
            self?.addPhoto(for: view)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            view.image = nil
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        updateUI()
    }
    
    private func updateUI() {
        promtView.isHidden = !isPromtVisible
        photosView.isHidden = isPromtVisible
    }
    
    private func startLoading() {
        bottomActionsView.isHidden = true
        loadingView.isHidden = false
        photosSectionView.isUserInteractionEnabled = false
        photosSectionView.alpha = 0.8
    }
    
    private func stopLoading() {
        bottomActionsView.isHidden = false
        loadingView.isHidden = true
        photosSectionView.isUserInteractionEnabled = true
        photosSectionView.alpha = 1.0
    }
    
    private func showUploadingErrorMessage() {
        let alertController = UIAlertController(title: "ERROR",
                                                message: "Can't upload photos. Please try again later",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showConnectionError() {
        let banner = NotificationBanner(customView: NoConnectionBannerView.instanceFromNib())
        banner.show(on: self.navigationController)
    }
    
    private func addImage(_ image: UIImage) {
        guard let emptyPhotoView = photoViews.first(where: { $0.image == nil }) else { return }
        emptyPhotoView.image = image
        updateUI()
    }
    
    private func addPhoto(for view: PhotoView? = nil) {
        guard CameraPickerController.isAvailable else { return }
        
        let cameraPicker = CameraPickerController()
        cameraPicker.prepare()
        
        cameraPicker.selectionHandler = { [weak self] (_, photo) in
            DispatchQueue.main.async {
                if let photoView = view {
                    photoView.image = photo
                } else {
                    self?.addImage(photo)
                }
                
                self?.dismiss(animated: true)
            }
        }
        
        cameraPicker.cancelationHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func addPhotoAction() {
        addPhoto()
    }

    @IBAction func continueAction() {
        uploadPhotos()
    }
    
    private func uploadPhotos() {
        let group = DispatchGroup()
        
        var numberOfUploadedPhotos: Int = 0
        
        startLoading()

        group.enter()
        uploadPhoto(at: 0) { [weak self] (success) in
            numberOfUploadedPhotos += (success ? 1 : 0)
            
            group.enter()
            self?.uploadPhoto(at: 1) { [weak self] (success) in
                numberOfUploadedPhotos += (success ? 1 : 0)
                
                group.enter()
                self?.uploadPhoto(at: 2) { (success) in
                    numberOfUploadedPhotos += (success ? 1 : 0)
                    group.leave()
                }

                group.leave()
            }

            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.stopLoading()

            if numberOfUploadedPhotos > 0 {
                self?.performSegue(withIdentifier: "setGender", sender: nil)
            } else {
                self?.showUploadingErrorMessage()
            }
        }
    }
    
    private func uploadPhoto(at index: Int, completion: @escaping (Bool)->Void) {
        guard index < selectedPhotos.count else {
            completion(false)
            return
        }
        
        guard let imageData = selectedPhotos[index].pngData() else {
            completion(false)
            return
        }
        
        DatingKit.user.set(photo: imageData) { (status) in
            completion(status == .succses)
        }
    }

}

private extension UIFont {
    var properForDevice: UIFont {
        if UIDevice.current.small {
            let smallerSize = pointSize * 0.8
            return withSize(smallerSize)
        } else {
            return self
        }
    }
}
