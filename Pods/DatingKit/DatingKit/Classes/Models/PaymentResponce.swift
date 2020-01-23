//
//  PaymentResponce.swift
//  FAWN
//
//  Created by Алексей Петров on 03/06/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public struct PaymentResponse: Decodable {
    
    public var httpCode: Double
    public var message: String
    public var needPayment: Bool
    public var data: PaymentData?
    
    enum CodingKeys: String, CodingKey {
        case httpCode = "_code"
        case message = "_msg"
        case needPayment = "_need_payment"
        case data = "_data"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        httpCode = try contanier.decode(Double.self, forKey: .httpCode)
        message = try contanier.decode(String.self, forKey: .message)
        needPayment = try contanier.decode(Bool.self, forKey: .needPayment)
        data = try contanier.decode(PaymentData.self, forKey: .data)
    }
}

public struct PaymentData: Decodable {
    
    public var payScreen:PayScreenData
    public var isShowTrial: Bool
//    public var showUponLogin: Bool
    public var trialInfo: TrialData?
    
    enum CodingKeys: String, CodingKey {
//        case showUponLogin = "show_upon_login"
        case payscreen
        case showTrial = "show_trial"
        case trial
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        payScreen = try contanier.decode(PayScreenData.self, forKey: .payscreen)
        isShowTrial = try contanier.decode(Bool.self, forKey: .showTrial)
        trialInfo = try? contanier.decode(TrialData.self, forKey: .trial)
//        showUponLogin = try contanier.decode(Bool.self, forKey: .showUponLogin)
    }
}

public struct PayScreenData: Decodable {
    
    public var users: Int
    public var usersSubstring: String
    public var buttonTitle: String
    public var generalPaymentInfo:GeneralPayScreenData
    public var leftPaymentScreen: SubPayScreenData
    public var rightPaymentScreen: SubPayScreenData
    
    enum CodingKeys: String, CodingKey {
        case users
        case left
        case center
        case right
        case button
        case usersSub = "users_sub"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        users = try contanier.decode(Int.self, forKey: .users)
        usersSubstring = try contanier.decode(String.self, forKey: .usersSub)
        buttonTitle = try contanier.decode(String.self, forKey: .button)
        generalPaymentInfo = try contanier.decode(GeneralPayScreenData.self, forKey: .center)
        leftPaymentScreen = try contanier.decode(SubPayScreenData.self, forKey: .left)
        rightPaymentScreen = try contanier.decode(SubPayScreenData.self, forKey: .right)
    }
    
}

public struct TrialData: Decodable {
    
    public var title: String
    public var productID: String
    public var firstTitle: String
    public var firstSubTitle: String
    public var secondTitle: String
    public var secondSubTitle: String
    public var tridTitle: String
    public var tridSubTitle: String
    public var buttonTitle: String
    public var buttonSubTitle: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case productID = "product_id"
        case firstTitle = "reason_1_title"
        case firstSubTitle = "reason_1_subtitle"
        case secondTitle = "reason_2_title"
        case secondSubTitle = "reason_2_subtitle"
        case tridTitle = "reason_3_title"
        case tridSubTitle = "reason_3_subtitle"
        case button = "button_title"
        case buttonSubTitle = "button_subtitle"
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        title = try contanier.decode(String.self, forKey: .title)
        firstTitle = try contanier.decode(String.self, forKey: .firstTitle)
        firstSubTitle = try contanier.decode(String.self, forKey: .firstSubTitle)
        secondTitle = try contanier.decode(String.self, forKey: .secondTitle)
        secondSubTitle = try contanier.decode(String.self, forKey: .secondSubTitle)
        tridTitle = try contanier.decode(String.self, forKey: .tridTitle)
        tridSubTitle = try contanier.decode(String.self, forKey: .tridSubTitle)
        buttonTitle = try contanier.decode(String.self, forKey: .button)
        buttonSubTitle = try contanier.decode(String.self, forKey: .buttonSubTitle)
        productID = try contanier.decode(String.self, forKey: .productID)
    }
    
}

public struct GeneralPayScreenData: Decodable {
    public var header: String
    public var name: String
    public var subname: String
    public var productID: String
    public var subtitle: String
    
    enum CodingKeys: String, CodingKey {
        case header
        case subname
        case name
        case productID = "product_id"
        case subtitle
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        name = try contanier.decode(String.self, forKey: .name)
        header = try contanier.decode(String.self, forKey: .header)
        subname = try contanier.decode(String.self, forKey: .subname)
        productID = try contanier.decode(String.self, forKey: .productID)
        subtitle = try contanier.decode(String.self, forKey: .subtitle)
    }
    
}

public struct SubPayScreenData: Decodable {
    public var name: String
    public var productID: String
    public var subtitle: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case productID = "product_id"
        case subtitle
    }
    
    public init(from decoder: Decoder) throws {
        let contanier = try decoder.container(keyedBy: CodingKeys.self)
        name = try contanier.decode(String.self, forKey: .name)
        productID = try contanier.decode(String.self, forKey: .productID)
        subtitle = try contanier.decode(String.self, forKey: .subtitle)
    }
    
}
/*
 {
 "_code": 200,
 "_msg": "OK",
 "_need_payment": false,
 "_data": {
 "payscreen": {
    "users": 816,
    "users_sub": "guys seen online during last 24 hours",
    "left": {
        "name": "3 Months",
        "product_id": "chat.fawn.3month",
        "subtitle": "@price per 3 months"
    },
    "center": {
        "header": "POPULAR",
        "name": "7 day trial",
        "subname": "FREE",
        "product_id": "chat.fawn.weekly_w_trial",
        "subtitle": "Then @price per week"
    },
    "right": {
        "name": "1 Year",
 "      product_id": "chat.fawn.annual",
        "subtitle": "@price per year"
    },
    "button": "Continue"
 },
 "show_trial": true,
 "trial": {
    "title": "Why not try? It costs nothing",
    "reason_1_title": "Just cancel during the trial",
    "reason_1_subtitle": "from App Store account settings. No questions asked",
    "reason_2_title": "No hidden fees",
    "reason_2_subtitle": "it’s actually 100% FREE during the trial period",
    "reason_3_title": "Just try it out",
    "reason_3_subtitle": "for couple of days and then make up your mind",
    "button_title": "Start 7-day FREE trial",
    "button_subtitle": "Then @price per week"
    }
 }
 }
 
 */
