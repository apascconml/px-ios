//
//  MercadoPagoCheckout+PaymentFlowHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckout: PXPaymentResultHandlerProtocol {
    func finishPaymentFlow(error: MPSDKError) {
        guard let reviewScreen = viewModel.pxNavigationHandler.navigationController.viewControllers.last as? PXReviewViewController else {
            return
        }

        reviewScreen.resetButton()
    }

    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: InstructionsInfo?) {
        viewModel.paymentResult = paymentResult
        viewModel.instructionsInfo = instructionsInfo

        if viewModel.pxNavigationHandler.navigationController.viewControllers.last as? PXReviewViewController != nil {
            PXAnimatedButton.animateButtonWith(paymentResult: paymentResult)
        } else {
            executeNextStep()
        }

    }

    func finishPaymentFlow(businessResult: PXBusinessResult) {
        // TODO: Remove
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
        self.viewModel.businessResult = businessResult
            if self.viewModel.pxNavigationHandler.navigationController.viewControllers.last as? PXReviewViewController != nil {
                PXAnimatedButton.animateButtonWith(businessResult: businessResult)
            } else {
                self.executeNextStep()
            }

//        })
    }
}
