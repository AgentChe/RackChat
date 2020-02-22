//
//  Request.swift
//  Alamofire
//
//  Created by Алексей Петров on 03/07/2019.
//

import Foundation

public protocol APIRequest {
    
    var url: String { get }
    
    var parameters: [ String : Any] { get }
    
    var useToken: Bool { get }
    
    func parse(data: Data) -> Response!
}

public protocol APIRequestV1 {

    var url: String { get }

    var parameters: [ String : Any] { get }

    var useToken: Bool { get }

    func parse(data: Data) -> Decodable!
}
