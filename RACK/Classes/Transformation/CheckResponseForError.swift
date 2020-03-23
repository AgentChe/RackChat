//
//  CheckForError.swift
//  RACK
//
//  Created by Andrey Chernyshev on 23/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

final class CheckResponseForError {
    static func letThroughError(response: Any) throws -> Any {
        try throwIfError(response: response)
        
        return response
    }
    
    static func throwIfError(response: Any) throws  {
        guard let json = response as? [String: Any] else {
            throw ApiError.responseNotValid
        }
        
        if let needPayment = json["_need_payment"] as? Bool, needPayment == true {
            throw PaymentError.needPaymentError
        }
        
        if let code = json["_code"] as? Int, code < 200 || code > 299 {
            throw ApiError.requestFailed
        }
    }
}
