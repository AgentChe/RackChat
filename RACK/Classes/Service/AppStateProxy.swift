//
//  AppStateProxy.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 30/10/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

import Foundation.NSUUID
import RxCocoa

final class AppStateProxy {
    struct ApplicationProxy {
        static let willResignActive = PublishRelay<Void>()
        static let didBecomeActive = PublishRelay<Void>()
    }
}
