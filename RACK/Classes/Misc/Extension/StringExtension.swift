//
//  StringExtension.swift
//  DrSmart
//
//  Created by Andrey Chernyshev on 04.07.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import UIKit.UIFont

extension String {
    static func choosePluralForm(byNumber: Int, one: String, two: String, many: String) -> String {
        var result = many
        let number = byNumber % 100
        
        if (number < 10 || number >= 20) {
            if (number % 10 == 1) {
                result = one
            }
            if (number % 10 > 1 && number % 10 < 5) {
                result = two
            }
        }
        return result
    }
    
    static var uuid_timeinterval: String {
        String(format: "%@_%@", UUID().uuidString, String(Date().timeIntervalSince1970))
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    var asBase64: String {
        data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) ?? ""
    }
    
    var fromBase64: String {
        let decodedData = Data(base64Encoded: self)!
        return String(data: decodedData, encoding: .utf8)!
    }
}
