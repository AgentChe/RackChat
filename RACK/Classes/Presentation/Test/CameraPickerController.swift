//
//  CameraPickerController.swift
//  RACK
//
//  Created by Alexey Prazhenik on 2/19/20.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import MobileCoreServices

class CameraPickerController : UIImagePickerController {
    typealias SelectCallbackHandler = (CameraPickerController, UIImage) -> ()
    typealias CancelCallbackHandler = (CameraPickerController) -> ()
    
    var selectionHandler: SelectCallbackHandler?
    var cancelationHandler: CancelCallbackHandler?
    
    static var isAvailable: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return UIImagePickerController.isCameraDeviceAvailable(.front)
#endif
    }

    func prepare() {
        self.delegate = self
        
        self.mediaTypes = [kUTTypeImage as String]
        self.allowsEditing = false
        
#if targetEnvironment(simulator)
        self.sourceType = .photoLibrary
#else
        self.sourceType = .camera
        self.cameraCaptureMode = .photo
        self.cameraDevice = .front
#endif
    }
        
}

extension CameraPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        
        let fixedImage = pickedImage.fixSize()
        selectionHandler?(self, fixedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelationHandler?(self)
    }
    
}
