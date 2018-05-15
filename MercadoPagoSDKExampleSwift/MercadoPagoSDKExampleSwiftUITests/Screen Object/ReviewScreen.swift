//
//  ReviewScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 16/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class ReviewScreen: BaseScreen {
    private lazy var payButton = element("Confirmar")
    private lazy var changePaymentMethodButton = element("Cambiar medio de pago")
    
    override func waitForElements() {
        waitFor(element: payButton)
    }

    func tapPayButtonForApproved() -> ApprovedScreen {
        payButton.tap()
        return ApprovedScreen()
    }

    func tapPayButtonForRejected() -> RejectedScreen {
        payButton.tap()
        return RejectedScreen()
    }

    func tapPayButtonForPending() -> PendingScreen {
        payButton.tap()
        return PendingScreen()
    }

    func tapPayButtonForInstructions() -> InstructionsScreen {
        payButton.tap()
        return InstructionsScreen()
    }

    func tapPayButtonForAnyCongrats() -> CongratsScreen {
        payButton.tap()
        return CongratsScreen()
    }

    func tapChangePaymentMethod() -> MainGroupScreen {

        //TODO: Add scrolling. If fails in small devices.
        changePaymentMethodButton.tap()
        return MainGroupScreen()
    }

//    func tapPayButton()  -> CongratsScreen{
//        payButton.tap()
//        return CongratsScreen()
//    }
}
