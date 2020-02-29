//
//  ConfigRequest.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import UIKit

class VersionRequest: APIRequest {
    
    func parse(data: Data) -> Response! {
        return nil
    }
    
    
    var url: String {
        return "/users/set_version"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init() {
        let number: Int = Int(Bundle.main.buildVersionNumber ?? "0")!
        parameters = ["version" : number,
                      "market" : 1]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}

class CurrentAppConfig {
    static let shared: CurrentAppConfig = CurrentAppConfig()
    var showUponRegistration: Bool = false
    var showIfMaleRegistration: Bool = false
    var showIfFemaleRegistration: Bool = false
    var currentGender: Gender = .none
    
    func setVersion(_ completion: @escaping(_ status: ResultStatus) -> Void) {
        DatingKit.set(version: Int(Bundle.main.buildVersionNumber ?? "0")!, market: 1) { (status) in
            completion(status)
        }
    }
    
    func setLocale() {
        guard let locale: String = NSLocale.current.languageCode else { return }
        DatingKit.set(locale: locale) { (status) in
        }
    }
    
    func setVersion() {
        DatingKit.isLogined { (isLogined) in
            if isLogined {
                DatingKit.set(version: Int(Bundle.main.buildVersionNumber ?? "0")!, market: 1) { (result) in
                    switch result {
                    case .succses:
                        break
                        
                    case .undifferentError:
                        
                        break
                        default:
                            debugPrint("config is failed")
                            break
                        }
                    }
                }
            }
    }
    
    func setGender(gender : Gender) {
        currentGender = gender
        
        switch gender {
       
        case .none:
            break
        case .man:
            if showIfMaleRegistration {
                showUponRegistration = true
            }
        case .woman:
            if showIfFemaleRegistration {
                showUponRegistration = true
            }
       
        }
    }
    
    func configure(_ completion: @escaping(_ status: ResultStatus) -> Void) {
        
        DatingKit.configurate(version: Int(Bundle.main.buildVersionNumber ?? "0")!, market: 1) { (result, status) in
            switch status {
                
            case .succses:
                self.showIfMaleRegistration = result!.needShowPaygateGuy
                self.showIfFemaleRegistration = result!.needShowPaygateGirl
                
                break
            default:
                debugPrint("config is failed")
                break
            }
            
            completion(status)
        }
    }
}
