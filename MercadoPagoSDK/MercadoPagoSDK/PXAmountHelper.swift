//
//  PXAmountHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 29/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

internal struct PXAmountHelper {

    internal let preference: CheckoutPreference
    internal let paymentData: PaymentData
    internal let discount: PXDiscount?
    internal let campaign: PXCampaign?

    var preferenceAmount: Double {
        get {
            return self.preference.getAmount()
        }
    }

    var amountToPay: Double {
        get {
            if let payerCost = paymentData.payerCost {
                return payerCost.totalAmount
            }
            if let couponAmount = discount?.couponAmount {
                return preferenceAmount - couponAmount
            } else {
                return preferenceAmount
            }
        }
    }

    var amountOff: Double {
        get {
            guard let discount = self.discount else {
                return 0
            }
            return discount.couponAmount
        }
    }

    var maxCouponAmount: Double? {
        get {
            if let maxCouponAmount = campaign?.maxCouponAmount, maxCouponAmount > 0.0 {
                return maxCouponAmount
            }
            return nil
        }
    }
}
