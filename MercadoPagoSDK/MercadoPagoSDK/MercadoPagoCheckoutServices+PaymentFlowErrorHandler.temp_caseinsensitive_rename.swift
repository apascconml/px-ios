//
//  MercadoPagoCheckoutServices+PaymentFlowErrorHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckout: PXPaymentResultHandler {
    func finishPaymentFlow(paymentResult: PaymentResult) {
        self.viewModel.paymentResult = paymentResult
        PXAnimatedButton.animateButtonWith(paymentResult: paymentResult)
    }

    func finishPaymentFlow(businessResult: PXBusinessResult) {
        self.viewModel.businessResult = businessResult
        PXAnimatedButton.animateButtonWith(businessResult: businessResult)
    }
}
