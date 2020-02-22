//
//  CitiesResponse.swift
//  FAWN
//
//  Created by Алексей Петров on 13/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation


public struct CitiesResponse: Response {
    
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var data: [CityItemResponse]?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
    }
    
}


public struct CityItemResponse: Decodable {

    public var cityID: Int
    public var name: String
    
    enum CodingKeys: String, CodingKey {
        case cityID = "id"
        case name
    }
    
}


public struct CityAddResponse: Response {
    
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var cityID: Int?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
        case cityID = "id"
    }

    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        
        let dataBox = try contanier.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        cityID = try dataBox.decode(Int.self, forKey: .cityID)
    }

}
