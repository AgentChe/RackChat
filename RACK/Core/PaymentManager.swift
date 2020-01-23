//
//  PaymentManager.swift
//  RACK
//
//  Created by Алексей Петров on 08/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation

import DatingKit
import StoreKit
import SwiftyStoreKit

enum RestoreStatus: Int {
    case restored
    case failed
}

enum BuyStatus: Int {
    case succes
    case error
    case unknown
    case clientInvalid
    case paymentCancelled
    case paymentInvalid
    case paymentNotAllowed
    case storeProductNotAvailable
    case cloudServicePermissionDenied
    case cloudServiceNetworkConnectionFailed
    case cloudServiceRevoked
}

class SetStoreCountry: APIRequestV1 {
    
    var url: String {
        return "/users/set_store_country"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(storeCountry: String) {
        parameters = ["store_country" : storeCountry]
    }
    
    func parse(data: Data) -> Decodable! {
          do {
              let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
              return response
          } catch let error {
              debugPrint(error.localizedDescription)
              return nil
          }
    }
}

class PurchaseRequset: APIRequestV1 {

    var url: String {
        return "/payments/paygate"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init() {
        parameters = [String : Any]()
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: PaymentResponse = try JSONDecoder().decode(PaymentResponse.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}

class ReciptValidate: APIRequestV1 { 
    
    var url: String {
        return "/payments/validate_receipt"
    }
    
    var parameters: [String : Any]
    
    var useToken: Bool {
        return true
    }
    
    init(receipt: String) {
        parameters = ["receipt" : receipt]
    }
    
    func parse(data: Data) -> Decodable! {
        do {
            let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
            return response
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
}

class PurchaseManager: NSObject {
    
    public static let shared: PurchaseManager = PurchaseManager()
    public var products: [String: SKProduct] = [:]
    public var paygateConfig: ConfigBundle?
    private var currentBundle: PaymentData?
    public var isLoaded: Bool = false
    public var showUponLogin: Bool = false
    var isStartLoad: Bool = false
    
    override init() {
        super.init()
    }
    
    func setStore(version: String) {
        let request: SetStoreCountry = SetStoreCountry(storeCountry: version)
        RequestManager.shared.requset(request) { (result) in
            debugPrint("set country", version)
        }
    }
    
    func gettingStart() {
        self.validateResipt {
            
        }
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.validateResipt {
                        
                    }
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
        
    }
    
    func getConfigBundle(_  completion: @escaping(_ : ConfigBundle?) -> Void) {
        if paygateConfig?.priceBundle.centralPriceTag.priseString != "0" {
            completion(paygateConfig!)
        } else {
            
            let request: PurchaseRequset = PurchaseRequset()
            RequestManager.shared.requset(request) { (response) in
                if response != nil {
                    let paygateData: PaymentResponse = response as! PaymentResponse
                    if paygateData.httpCode == 200 {
                        self.currentBundle = paygateData.data!
                        let paygateConfig: ConfigBundle = ConfigBundle(payment: paygateData.data!, with: "0", leftPrice: "0", rightPrice: "0", trialPrice: "0")
                        self.paygateConfig = paygateConfig
                        completion(paygateConfig)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
                
                
            }
        }
    }
    
    func loadProducts(_ completion: @escaping(_ paygateConfig: ConfigBundle?) -> Void) {
        let request: PurchaseRequset = PurchaseRequset()
        if isStartLoad == false  {
            isStartLoad = true
            RequestManager.shared.requset(request) { (response) in
                if response != nil {
                    let paygateData: PaymentResponse = response as! PaymentResponse
                    if paygateData.httpCode == 200 {
                        SwiftyStoreKit.retrieveProductsInfo(self.getProductIDs(from: paygateData.data!), completion: { (results) in
                            
                            if let item: SKProduct = results.retrievedProducts.first {
                                self.setStore(version: item.priceLocale.currencyCode!)
                            }
                            
                            results.retrievedProducts.forEach { product in
                                print("Valid: \(product)")
                                self.products[product.productIdentifier] = product
                                SKProductStorePromotionController.default().update(storePromotionVisibility: SKProductStorePromotionVisibility.default,
                                                                                   for: product,
                                                                                   completionHandler: { (error) in
                                                                                    if error != nil {
                                                                                        debugPrint(error!.localizedDescription)
                                                                                    } else {
                                                                                        debugPrint("Succses")
                                                                                    }
                                })
                            }
                            
                            let returnedConfig: ConfigBundle = self.configBundle(with: self.products, and: paygateData.data!)
                            
                            self.validateResipt {
                                self.isLoaded = true
                                self.isStartLoad = false
                                completion(returnedConfig)
                            }
                        })
                    } else {
                        completion(nil)
                    }
                    
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func getProductIDs(from bundle: PaymentData) -> Set<String> {
        var productsIds: Set<String> = []
        let firstID: String = bundle.payScreen.generalPaymentInfo.productID
        let secondID: String = bundle.payScreen.leftPaymentScreen.productID
        let thriedID: String = bundle.payScreen.rightPaymentScreen.productID
        productsIds = [firstID, secondID, thriedID]
        if bundle.isShowTrial {
            let trialID: String = bundle.trialInfo!.productID
            productsIds.insert(trialID)
            
        }
        return productsIds
    }
    
    private func validateResipt(_ completion: @escaping() -> Void) {
        if let receipt: Data = self.loadReceipt() {
            let receiptStr: String = receipt.base64EncodedString(options: .endLineWithLineFeed)
            let request: ReciptValidate = ReciptValidate(receipt: receiptStr)
            RequestManager.shared.requset(request) { (result) in
                completion()
            }
        } else {
            completion()
        }
    }
    
    private func configBundle(with products: [String: SKProduct], and bundle: PaymentData) -> ConfigBundle {
        var config: ConfigBundle = ConfigBundle(payment: bundle, with: "", leftPrice: "", rightPrice: "", trialPrice: "")
        if products.count == 0 {
            return config
        }
        let firstKey: String = bundle.payScreen.generalPaymentInfo.productID
        let firstProduct: SKProduct = products[firstKey]!
        let secondKey: String = bundle.payScreen.leftPaymentScreen.productID
        let secondProduct: SKProduct = products[secondKey]!
        let triedKey: String = bundle.payScreen.rightPaymentScreen.productID
        let triedProduct: SKProduct = products[triedKey]!
        if let trialKey: String = bundle.trialInfo?.productID {
            let trialProduct: SKProduct  = products[trialKey]!
            config = ConfigBundle(payment: bundle, with: firstProduct.localizedPrice, leftPrice: secondProduct.localizedPrice, rightPrice: triedProduct.localizedPrice, trialPrice: trialProduct.localizedPrice)
        } else {
            config = ConfigBundle(payment: bundle, with: firstProduct.localizedPrice, leftPrice: secondProduct.localizedPrice, rightPrice: triedProduct.localizedPrice, trialPrice: "0")
        }
        
        return config
    }
    
    func buy(productID: String, with completion: @escaping(_ status: BuyStatus) -> Void) {
        SwiftyStoreKit.purchaseProduct(products[productID]!) { (result) in
            switch result {
            case .success( _):
                self.validateResipt {
                    completion(.succes)
                    NotificationCenter.default.post(name: PaymentManager.wasPurchased, object: nil)
                }
                break
            case .error(let error):
                switch error.code {
                case .unknown:
                    self.validateResipt {completion(.unknown)}
                case .clientInvalid: completion(.clientInvalid)
                case .paymentCancelled:
                    self.validateResipt {
                        completion(.paymentCancelled)
                    }
                case .paymentInvalid: completion(.paymentInvalid)
                case .paymentNotAllowed: completion(.paymentNotAllowed)
                case .storeProductNotAvailable: completion(.storeProductNotAvailable)
                case .cloudServicePermissionDenied: completion(.cloudServicePermissionDenied)
                case .cloudServiceNetworkConnectionFailed: completion(.cloudServiceNetworkConnectionFailed)
                case .cloudServiceRevoked: completion(.cloudServiceRevoked)
                default:
                    print((error as NSError).localizedDescription)
                    completion(.unknown)
                }
            }
        }
    }
    
    func restore(_ completion: @escaping(_ status: RestoreStatus) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
               
                completion(.failed)
            }
            else if results.restoredPurchases.count > 0 {
                self.validateResipt {
                    completion(.restored)
                }
            }
            else {
                completion(.failed)
            }
        }
    }
    
    private func loadReceipt() -> Data? {
        return SwiftyStoreKit.localReceiptData
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        validateResipt {  }
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}
