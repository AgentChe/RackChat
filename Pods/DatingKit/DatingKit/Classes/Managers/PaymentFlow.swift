//
//  PaymentFlow.swift
//  FAWN
//
//  Created by Алексей Петров on 03/06/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import PromiseKit

public struct ConfigTrial {
    
    public var title: String
    
    public var reasons: [Reason]
    public var button: Button
    public var productID: String
    
    public init(trialInfo: TrialData, and price: String) {
        
        title = trialInfo.title
        
        reasons = [Reason]()
        
        reasons.append(Reason(title: trialInfo.firstTitle, subtitle: trialInfo.firstSubTitle))
        reasons.append(Reason(title: trialInfo.secondTitle, subtitle: trialInfo.secondSubTitle))
        reasons.append(Reason(title: trialInfo.tridTitle, subtitle: trialInfo.tridSubTitle))
        
        button = Button(title: trialInfo.buttonTitle, subtitle: trialInfo.buttonSubTitle, price: price)
        self.productID = trialInfo.productID
    }
}

public struct Reason {
    
    public var title: String
    public var subTitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        subTitle = subtitle
       
    }
}

public struct Button {
    
    public var title: String
    public var subTitle: String
    
    public init(title: String, subtitle: String, price: String) {
        self.title = title
        subTitle = subtitle.replacingOccurrences(of: "@price", with: price, options: .literal, range: nil)
    }
}

public struct ConfigBundle {
    
    public var mensCounterBundle: FirstBandleInfo
    public var priceBundle:SecondBandleInfo
    public var buttonBundle: ButtonBandleInfo
    public var isShowTrial: Bool
    public var showUponLogin: Bool
    public var configTrial: ConfigTrial?
    
    public init(payment: PaymentData, with generalPrice: String, leftPrice: String, rightPrice: String, trialPrice: String) {
        mensCounterBundle = FirstBandleInfo(payscreen: payment.payScreen)
        priceBundle = SecondBandleInfo(centerInfo: payment.payScreen.generalPaymentInfo, and: generalPrice,
                                       leftInfo: payment.payScreen.leftPaymentScreen, and: leftPrice,
                                       rightInfo: payment.payScreen.rightPaymentScreen, rightPrice: rightPrice)
        buttonBundle = ButtonBandleInfo(name: payment.payScreen.buttonTitle)
        isShowTrial = payment.isShowTrial
        showUponLogin = false
        if isShowTrial {
            configTrial = ConfigTrial(trialInfo: payment.trialInfo!, and: trialPrice)
        }
    }
}

public struct FirstBandleInfo {
    public var usersCount: Int
    public var usersSubstring: String
    
    public init(payscreen: PayScreenData) {
        usersCount = payscreen.users
        usersSubstring = payscreen.usersSubstring
    }
}

public struct CentralPriceTag {
    
   public var headerString: String
   public var name: String
   public var subname: String
   public var priseString: String
   public var id: String
    
   init(generalPaymenInfo: GeneralPayScreenData, and price: String) {
        id = generalPaymenInfo.productID
        headerString = generalPaymenInfo.header
        name = generalPaymenInfo.name
        subname = generalPaymenInfo.subname
        priseString = generalPaymenInfo.subtitle.replacingOccurrences(of: "@price", with: price, options: .literal, range: nil)
    }
}

public struct SubPriceTag {
   public var name: String
   public var priceString: String
   public var id: String
   public var nameNum: String
    
   public init(subPaymentInfo: SubPayScreenData, and price: String) {
        id = subPaymentInfo.productID
        name = subPaymentInfo.name
        name.removeFirst()
        priceString = subPaymentInfo.subtitle.replacingOccurrences(of: "@price", with: price, options: .literal, range: nil)
        let index = subPaymentInfo.name.index(subPaymentInfo.name.startIndex, offsetBy: 1)
        nameNum = String(subPaymentInfo.name.prefix(upTo: index))
    }
}

public struct SecondBandleInfo {
    public var centralPriceTag: CentralPriceTag
    public var leftPriceTag: SubPriceTag
    public var reightPriceTag: SubPriceTag
    
    public init(centerInfo: GeneralPayScreenData, and generalPrice: String, leftInfo: SubPayScreenData, and leftPrice: String, rightInfo: SubPayScreenData, rightPrice: String) {
        centralPriceTag = CentralPriceTag(generalPaymenInfo: centerInfo, and: generalPrice)
        leftPriceTag = SubPriceTag(subPaymentInfo: leftInfo, and: leftPrice)
        reightPriceTag = SubPriceTag(subPaymentInfo: rightInfo, and: rightPrice)
    }
}

public struct ButtonBandleInfo {
   public var name: String
    
    init(name: String) {
        self.name = name
    }
}


public protocol PaymentFlowDelegate: class {
    func paymentInfoWasLoad(config bundle: ConfigBundle)
    func paymentSuccses()
    func error()
    func purchase()
}

open class PaymentFlow {
    
    public static let shared: PaymentFlow = PaymentFlow()
    
    public weak var delegate: PaymentFlowDelegate?
    
    public let manager: PaymentManager
    private var currentBundle: PaymentData?
    
    public var serverInfoWasLoad: Bool = false
    public var isLoaded: Bool = false
    public var showUponLogin: Bool = false
    var isStartLoad: Bool = false
    
    public var paygateConfig: ConfigBundle?
    
    public init() {
        manager = PaymentManager()
        manager.delegate = self
    }
    
    public func loadServerData(_ completion: @escaping(_ pymentConfig: ConfigBundle?) -> Void) {
        serverInfoWasLoad = false
        RequestManager.shared.request(.purchaseGate, params: [String : Any]()) { [weak self] (response) in
            if response != nil {
                let paygateData: PaymentResponse = response as! PaymentResponse
                if  paygateData.httpCode == 200 {
                    guard let firstID: String = paygateData.data?.payScreen.generalPaymentInfo.productID else { return }
                    guard let secondID: String = paygateData.data?.payScreen.leftPaymentScreen.productID else { return }
                    guard let thriedID: String = paygateData.data?.payScreen.rightPaymentScreen.productID else { return }
                    let trialID: String = (paygateData.data?.trialInfo?.productID) ?? ""
                    
                    var IDs:[String] = [firstID, secondID, thriedID]
                    if trialID != "" {
                        IDs.append(trialID)
                    }
                    if self!.isStartLoad == false {
                        self?.isStartLoad = true
                        self?.manager.fetchAvailableProducts(with: IDs)
                    }
                   
                    
                    self?.currentBundle = paygateData.data!
//                    self?.showUponLogin = paygateData.data!.showUponLogin
                    self?.serverInfoWasLoad = true
                    let paygateConfig: ConfigBundle = ConfigBundle(payment: paygateData.data!, with: "0", leftPrice: "0", rightPrice: "0", trialPrice: "0")
                    self?.paygateConfig = paygateConfig
                    completion(paygateConfig)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    public func start() {
        serverInfoWasLoad = false
        RequestManager.shared.request(.purchaseGate, params: [String : Any]()) { [weak self] (response) in
            if response != nil {
                let paygateData: PaymentResponse = response as! PaymentResponse
                if  paygateData.httpCode == 200 {
                    guard let firstID: String = paygateData.data?.payScreen.generalPaymentInfo.productID else { return }
                    guard let secondID: String = paygateData.data?.payScreen.leftPaymentScreen.productID else { return }
                    guard let thriedID: String = paygateData.data?.payScreen.rightPaymentScreen.productID else { return }
                    let trialID: String = (paygateData.data?.trialInfo?.productID) ?? ""
                    
                    var IDs:[String] = [firstID, secondID, thriedID]
                    if trialID != "" {
                        IDs.append(trialID)
                    }
                    if self!.isStartLoad == false {
                        self?.isStartLoad = true
                        self?.manager.fetchAvailableProducts(with: IDs)
                    }
                    
                    self?.currentBundle = paygateData.data!
//                    self?.showUponLogin = paygateData.data!.showUponLogin
                    self?.serverInfoWasLoad = true
                    self?.paygateConfig = ConfigBundle(payment: paygateData.data!, with: "0", leftPrice: "0", rightPrice: "0", trialPrice: "0")
                }
            } else {
                self!.delegate?.error()
            }
        }
    }
    
}



extension PaymentFlow: PaymentManagerDelegate {
    
    func purchase() {

        self.delegate?.purchase()
    }
    
    public func purchasing(_ pyamentManager: PaymentManager) {
        self.delegate?.purchase()
    }
    
    public func succsesPay(_ pyamentManager: PaymentManager) {
        guard let receipt: Data = pyamentManager.loadReceipt() else { return }
        let receiptStr: String = receipt.base64EncodedString(options: .endLineWithLineFeed)
        RequestManager.shared.request(.purchaseValidate, params: ["receipt" : receiptStr]) { (result) in
            self.delegate?.paymentSuccses()
            NotificationCenter.default.post(name: PaymentManager.wasPurchased, object: nil)
        }
    }
    
    public func failedPay(_ pyamentManager: PaymentManager) {
        delegate?.error()
    }
    
    public func restored(_ pyamentManager: PaymentManager) {
        guard let receipt: Data = pyamentManager.loadReceipt() else { return }
        let receiptStr: String = receipt.base64EncodedString(options: .endLineWithLineFeed)
        RequestManager.shared.request(.purchaseValidate, params: ["receipt" : receiptStr]) { [weak self] (result) in
            self!.delegate?.paymentSuccses()
        }
    }
    
    public func manager(_ pyamentManager: PaymentManager, load products: [String : SKProduct]) {
        let firstKey: String = (currentBundle?.payScreen.generalPaymentInfo.productID)!
        let firstProduct: SKProduct = products[firstKey]!
        let secondKey: String = (currentBundle?.payScreen.leftPaymentScreen.productID)!
        let secondProduct: SKProduct = products[secondKey]!
        let triedKey: String = (currentBundle?.payScreen.rightPaymentScreen.productID)!
        let triedProduct: SKProduct = products[triedKey]!
        if let trialKey: String = currentBundle?.trialInfo?.productID {
            var trialProduct: SKProduct  = products[trialKey]!
            paygateConfig = ConfigBundle(payment: currentBundle!, with: firstProduct.localizedPrice, leftPrice: secondProduct.localizedPrice, rightPrice: triedProduct.localizedPrice, trialPrice: trialProduct.localizedPrice)
        } else {
             paygateConfig = ConfigBundle(payment: currentBundle!, with: firstProduct.localizedPrice, leftPrice: secondProduct.localizedPrice, rightPrice: triedProduct.localizedPrice, trialPrice: "")
        }
        
       
        
        if let receipt: Data = pyamentManager.loadReceipt() {
//        if receipt != nil {
            let receiptStr: String = receipt.base64EncodedString(options: .endLineWithLineFeed)
            RequestManager.shared.request(.purchaseValidate, params: ["receipt" : receiptStr]) { [weak self] (result) in
                self?.isLoaded = true
                self?.isStartLoad = false
                self?.delegate?.paymentInfoWasLoad(config: self!.paygateConfig!)
            }
        } else {
                self.delegate?.paymentInfoWasLoad(config: self.paygateConfig!)
        }
    }
    
}
