//
//  MainGroupScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class MainGroupScreen: BaseScreen {

    lazy var cardButton = cellWith(text: "Tarjetas")
    
    override func waitForElements() {
        waitFor(element: cardButton)
    }
    func tapCardOption() -> CardsOptionsScreen {
        cardButton.tap()
        return CardsOptionsScreen()
    }
}

class CardsOptionsScreen: BaseScreen {
    private lazy var creditCardButton = cellWith(text: "Tarjeta de crédito")

    func tapCreditCardOption() -> CardScreen{
        creditCardButton.tap()
    }
    override func waitForElements() {
        waitFor(element: creditCardButton)
    }
}
