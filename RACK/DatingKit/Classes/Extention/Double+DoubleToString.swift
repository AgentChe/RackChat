//
//  Double+DoubleToString.swift
//  FAWN
//
//  Created by Алексей Петров on 20/06/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public extension Double {
    public func toString() -> String {
        return String(format: "%.1f",self)
    }
}
