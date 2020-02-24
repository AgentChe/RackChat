//
//  DictionaryExtension.swift
//  RACK
//
//  Created by Andrey Chernyshev on 25/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Foundation.NSJSONSerialization

extension Dictionary {
    func jsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .ascii)
        } catch {
            return nil
        }
    }
}
