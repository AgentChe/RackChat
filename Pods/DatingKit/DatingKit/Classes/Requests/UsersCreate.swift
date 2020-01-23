//
//  TechnicalRequest.swift
//  Alamofire
//
//  Created by Алексей Петров on 03/07/2019.
//

import Foundation

public class UsersCreate: APIRequest {
    
    public var url: String {
        return "/users/create"
    }
    
    public var parameters: [String : Any]
    
    public var useToken: Bool = false
    
    public init(parameters: [String : Any]) {
        self.parameters = parameters
    }
    
    public func parse(data: Data) -> Response! {
        do {
            let response: TechnicalCreate = try JSONDecoder().decode(TechnicalCreate.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}
