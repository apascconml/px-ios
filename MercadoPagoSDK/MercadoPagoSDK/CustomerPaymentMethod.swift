//
//  CustomerPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CustomerPaymentMethod: NSObject, CardInformation, PaymentMethodOption {

    var customerPaymentMethodId: String!
    var customerPaymentMethodDescription: String!
    var paymentMethodId: String!
    var paymentMethodTypeId: String!
    var firstSixDigits: String!

    var securityCode: SecurityCode = SecurityCode()
    var paymentMethod: PaymentMethod?
    var card: Card?

    public override init() {
        super.init()
    }

    public init(id: String, paymentMethodId: String, paymentMethodTypeId: String, description: String) {
        self.customerPaymentMethodId = id
        self.paymentMethodId = paymentMethodId
        self.paymentMethodTypeId = paymentMethodTypeId
        self.customerPaymentMethodDescription = description
    }

    open class func fromJSON(_ json: NSDictionary) -> CustomerPaymentMethod {
        let  customerPaymentMethod = CustomerPaymentMethod()

        if json["id"] != nil && !(json["id"]! is NSNull) {
            customerPaymentMethod.customerPaymentMethodId = json["id"] as! String
        }

        if json["description"] != nil && !(json["description"]! is NSNull) {
            customerPaymentMethod.customerPaymentMethodDescription = json["description"] as! String
        }

        if json["payment_method_id"] != nil && !(json["payment_method_id"]! is NSNull) {
            customerPaymentMethod.paymentMethodId = json["payment_method_id"] as! String
        }

        if json["payment_method_type"] != nil && !(json["payment_method_type"]! is NSNull) {
            customerPaymentMethod.paymentMethodTypeId = json["payment_method_type"] as! String
        }
        if json["first_six_digits"] != nil && !(json["first_six_digits"]! is NSNull) {
            customerPaymentMethod.firstSixDigits = json["first_six_digits"] as! String
        }

        return customerPaymentMethod
    }

    public func getIssuer() -> Issuer? {

        return card?.issuer
    }

    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "_id": self.customerPaymentMethodId,
            "_description": self.customerPaymentMethodDescription == nil ? "" : self.customerPaymentMethodDescription!,
            "payment_method_id": self.paymentMethodId,
            "payment_method_type": self.paymentMethodTypeId
        ]

        return obj
    }

    public func getFirstSixDigits() -> String? {
        return card?.getCardBin()
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func isSecurityCodeRequired() -> Bool {
        return true
    }

    open func getCardId() -> String {
        return self.customerPaymentMethodId
    }

    open func getCardSecurityCode() -> SecurityCode {
        return self.securityCode
    }

    open func getCardDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    open func getPaymentMethod() -> PaymentMethod? {
        return paymentMethod
    }

    open func getPaymentMethodId() -> String {
        return self.paymentMethodId
    }

    open func getPaymentTypeId() -> String {
        return self.paymentMethodTypeId
    }

    open func getCardBin() -> String? {
        return card?.getCardBin()
    }

    open func getCardLastForDigits() -> String? {
        return card?.getCardLastForDigits()
    }

    open func setupPaymentMethod(_ paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    open func setupPaymentMethodSettings(_ settings: [Setting]) {
        self.securityCode = settings[0].securityCode
    }

    public func isIssuerRequired() -> Bool {
        return false
    }

    /** PaymentOptionDrawable implementation */

    public func getTitle() -> String {
        return getCardDescription()
    }

    public func getSubtitle() -> String? {
        return nil
    }

    public func getImage() -> UIImage? {
        return MercadoPago.getImageForPaymentMethod(withDescription: self.getPaymentMethodId())
    }

    /** PaymentMethodOption  implementation */

    public func hasChildren() -> Bool {
        return false
    }

    public func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    public func getId() -> String {
        return self.customerPaymentMethodId
    }

    public func isCustomerPaymentMethod() -> Bool {
        return true
    }

    public func isCard() -> Bool {

        return PaymentTypeId.isCard(paymentTypeId: self.paymentMethodTypeId)
    }

    public func getDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    public func getComment() -> String {
        return ""
    }

    public func canBeClone() -> Bool {
        return false
    }
}
