//
//  UrlExtension.swift
//  SleepWell
//
//  Created by Alexander Mironov on 24/12/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

import Foundation.NSURL

extension URL {
    static func combain(domain: String, path: String) -> URL? {
        return URL(string: domain + path)
    }
}
