//
//  CardScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 13/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class CardScreen: BaseScreen {

    private lazy var numberTextField = textField("Número de tarjeta")
    private lazy var nameTextField = textField("Nombre y apellido")
    private lazy var expirationDateTextField = textField("Fecha de expiración")
    private lazy var cvvTextField = textField("Código de seguridad")
    private lazy var continueButton = toolbarButton("Continuar")
    
    override func waitForElements() {
        waitFor(element: numberTextField)
    }
    
    func completeNumberAndContinue(_ text: String) -> CardScreen{
        numberTextField.typeText(text)
        continueButton.tap()
        return self
    }
    func completeNameAndContinue(_ text: String) -> CardScreen{
        nameTextField.typeText(text)
        continueButton.tap()
        return self
    }
    func completeExpirationDateAndContinue(_ text: String) -> CardScreen{
        expirationDateTextField.typeText(text)
        continueButton.tap()
        return self
    }
    func completeCVVAndContinue(_ text: String) -> IdentificationScreen{
        waitFor(element: cvvTextField)
        cvvTextField.typeText(text)
        continueButton.tap()
        return IdentificationScreen()
    }
}
