//
//  CardScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 13/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

public class CardScreen: BaseScreen {

    private lazy var cardFormTextField = textField("card_form_text_field")
    private lazy var continueToolbarButton = toolbarButton("Continuar")
    private lazy var backToolbarButton = toolbarButton("Anterior")
    private lazy var invalidCardLabel = element("No puedes pagar con esta tarjeta")
    private lazy var availableCardsButton = element("MÁS INFO")


    override open func waitForElements() {
        waitFor(element: cardFormTextField)
    }

    func completeNumberAndContinue(_ text: String) -> CardScreen{
        cardFormTextField.typeText(text)
        continueToolbarButton.tap()
        return self
    }

    func completeNumberAndExpectInvalidFieldError(_ text: String) -> CardScreen{
        cardFormTextField.typeText(text)
        waitFor(element: invalidCardLabel)
        return self
    }

    func tapAvailableCardsButton() -> CardScreen{
        waitFor(element: availableCardsButton)
        availableCardsButton.tap()
        return self
    }

    func completeNameAndContinue(_ text: String) -> CardScreen{
        cardFormTextField.typeText(text)
        continueToolbarButton.tap()
        return self
    }

    func completeExpirationDateAndContinue(_ text: String) -> CardScreen{
        cardFormTextField.typeText(text)
        continueToolbarButton.tap()
        return self
    }

    func completeCVVAndContinue(_ text: String) -> IdentificationScreen{
        waitFor(element: cardFormTextField)
        cardFormTextField.typeText(text)
        continueToolbarButton.tap()
        return IdentificationScreen()
    }

    func pressPreviousButton() -> CardScreen {
        backToolbarButton.tap()
        return self
    }

    func validateTextField(with text: String) -> CardScreen {
        let cardScreen = validate { (cardScreen) in
            XCTAssert(cardScreen.textField(text).exists)
        }
        return cardScreen
    }
}
