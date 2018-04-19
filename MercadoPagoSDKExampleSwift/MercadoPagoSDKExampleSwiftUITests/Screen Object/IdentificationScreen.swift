//
//  IdentificationScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 16/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class IdentificationScreen: BaseScreen {

    private lazy var numberTextField = textField("Número")
    private lazy var continueButton = toolbarButton("Continuar")
    
    override func waitForElements() {
        waitFor(element: numberTextField)
    }
    
    func completeNumberAndContinue(_ text: String) -> PayerCostScreen {
        numberTextField.typeText(text)
        continueButton.tap()
        return PayerCostScreen()
    }

}
