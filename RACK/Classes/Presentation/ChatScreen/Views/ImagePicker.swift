//
//  ImagePicker.swift
//  RACK
//
//  Created by Andrey Chernyshev on 03/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit

final class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let imagePicker = UIImagePickerController()
    
    private var handler: ((UIImage) -> ())?
    
    override init() {
        super.init()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        handler?(image)
    }
    
    func present(from vc: UIViewController, handler: ((UIImage) -> ())? = nil) {
        self.handler = handler
        
        vc.present(imagePicker, animated: true)
    }
}
