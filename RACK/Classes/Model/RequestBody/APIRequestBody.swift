//
//  APIRequestBody.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 25/10/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

import Alamofire

protocol APIRequestBody {
    var url: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: [String: String]? { get }
    var encoding: ParameterEncoding { get }
    var cookies: [HTTPCookie] { get }
}

extension APIRequestBody {
    var url: String {
        ""
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var headers: [String: String]? {
        nil
    }
    
    var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    var cookies: [HTTPCookie] {
        []
    }
}
