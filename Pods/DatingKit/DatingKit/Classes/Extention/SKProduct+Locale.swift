//
//  SKProduct+Locale.swift
//  FAWN
//
//  Created by Алексей Петров on 12/06/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import StoreKit

public extension SKProduct {
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    var localizedPrice: String {
        if self.price == 0.00 {
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale
            
            guard let formattedPrice = formatter.string(from: self.price)else {
                return "Unknown Price"
            }
            
            return formattedPrice
        }
    }
}
