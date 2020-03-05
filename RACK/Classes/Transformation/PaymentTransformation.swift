//
//  PaymentTransformation.swift
//  RACK
//
//  Created by Andrey Chernyshev on 06/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

final class PaymentTransformation {
    static func checkNeedPayment(response: Any) throws -> Bool {
        guard let json = response as? [String: Any], let needPayment = json["_need_payment"] as? Bool else {
            throw PaymentError.checkNeedPaymentError
        }
        
        return needPayment
    }
}
