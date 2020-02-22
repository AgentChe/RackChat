//
//  PaymentManagment.swift
//  FAWN
//
//  Created by Алексей Петров on 29/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import StoreKit

public protocol PaymentManagerDelegate: class {
    func succsesPay(_ pyamentManager: PaymentManager)
    func failedPay(_ pyamentManager: PaymentManager)
    func restored(_ pyamentManager: PaymentManager)
    func manager(_ pyamentManager: PaymentManager, load products: [String: SKProduct])
    func purchasing(_ pyamentManager: PaymentManager)
}

open class PaymentManager: NSObject {
    
    public static let wasPurchased = Notification.Name("wasPurchased")
    public static let needPayment = Notification.Name("needPayment")
    
    public weak var delegate: PaymentManagerDelegate?
    public var productID = ""
    public var productsRequest = SKProductsRequest()
    public var products: [String: SKProduct] = [:]
    
    public override init() {
        super.init()
    }
    
    public func buy(productID: String)  {
        if canMakePurchases() {
            if products.count > 0 {
                purchase(productID: productID)
            }
        }
    }
    
    public func purchase(productID: String){
        if products.count == 0 { return }
        if self.canMakePurchases() {
            let product = products[productID]
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product!.productIdentifier)")
            self.productID = product!.productIdentifier
        } else {
            debugPrint("some error")
        }
    }
    
    public func restore() {
        if (SKPaymentQueue.canMakePayments()) {
            
            SKPaymentQueue.default().restoreCompletedTransactions()
            delegate?.restored(self)
        }
    }
    
   public func fetchAvailableProducts(with IDs: [String])  {
        let productIDs = Set(IDs)
        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    public func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)

            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier


            // IAP Purchases dsabled on the Device
        } else {
           debugPrint("some message")
        }
    }
    
    public func loadReceipt() -> Data? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        guard let receiptData = try? Data(contentsOf: receiptUrl) else {
                return nil
        }
//        let str: String = receiptData.base64EncodedString(options: .lineLength64Characters)
        return receiptData
        
    }
}

extension PaymentManager: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .deferred:
                    break
                    
                case .purchasing:
//                    delegate?.purchasing(self)
                    break
                case .purchased:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    delegate?.succsesPay(self)
                    break
                case .failed:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    delegate?.failedPay(self)
                    break
                case .restored:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    delegate?.restored(self)
                    break
                default: break
                }}}
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }


}

extension PaymentManager: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
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
       
//        SKProductStorePromotionController.default().update(storePromotionOrder: response.products) { (error) in
//            if error != nil {
//                debugPrint(error?.localizedDescription)
//            } else {
//                debugPrint("Succses")
//            }
//        }
        
        delegate?.manager(self, load: products)
        productsRequest = SKProductsRequest()
    }
    
   public  func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }

}
