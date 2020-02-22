//
//  File.swift
//  FAWN
//
//  Created by Алексей Петров on 16/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation


open class CitiesResult: Result {
    
    public var status: ResultStatus
    public var cities: [CityItem]?
            
    init(response: CitiesResponse, status: ResultStatus) {
        self.status = status
        self.cities = response.data?.map({ CityItem(response: $0) })
    }
    
}


public struct CityItem {
    
    public var cityID: Int
    public var name: String
    
    public init(response: CityItemResponse) {
        self.cityID = response.cityID
        self.name = response.name
    }
    
    public init(cityID: Int, name: String) {
        self.cityID = cityID
        self.name = name
    }

}


open class CityAddResult: Result {
    
    public var status: ResultStatus
    public var cityID: Int?
    
    init(response: CityAddResponse, status: ResultStatus) {
        self.status = status
        self.cityID = response.cityID
    }

    public init(cityID: Int? = nil, status: ResultStatus) {
        self.status = status
        self.cityID = cityID
    }

}
