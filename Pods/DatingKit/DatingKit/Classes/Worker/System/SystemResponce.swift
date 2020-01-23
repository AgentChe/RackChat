//
//  SystemResponce.swift
//  DatingKit
//
//  Created by Алексей Петров on 30/09/2019.
//

import Foundation

struct SystemConfiguration: Response {
    
    public var message: String
    
    public var needPayment: Bool {
        return false
    }
    
    public var httpCode: Double

    public var showFemale: Bool
    public var showMale:Bool
    
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case messgeFromServer = "_msg"
        case data = "_data"
        case showFemale = "female_show_paygate_upon_registration"
        case showMale = "male_show_paygate_upon_registration"
        
    }
    
    init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .messgeFromServer)
        let box = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        showFemale = try box.decode(Bool.self, forKey: .showFemale)
        showMale = try box.decode(Bool.self, forKey: .showMale)
    }
}

