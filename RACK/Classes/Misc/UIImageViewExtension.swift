//
//  UIImageView+Download.swift
//  RACK
//
//  Created by Алексей Петров on 03/08/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloaded(from url: URL, complation: @escaping() -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                complation()
                return
            }
            DispatchQueue.main.async() {
                self.image = image
                complation()
            }
            }.resume()
    }
    
    func downloaded(from link: String, complation: @escaping() -> Void) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url) {
            complation()
        }
    }
}
