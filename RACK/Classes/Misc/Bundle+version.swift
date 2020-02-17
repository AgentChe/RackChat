//
//  Bundle+version.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
