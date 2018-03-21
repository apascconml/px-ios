//
//  MainGroupScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class MainGroupScreen: BaseScreen {

    lazy var cardButton = cell("Tarjetas")
    lazy var cashButton = cell("Pago en efectivo")
    
    override func waitForElements() {
        waitFor(element: cardButton)
    }
    func tapCardOption() -> CardsOptionsScreen {
        cardButton.tap()
        return CardsOptionsScreen()
    }
    
    func tapCashOption() -> CashOptionsScreen {
        cashButton.tap()
        return CashOptionsScreen()
    }
}

class CardsOptionsScreen: BaseScreen {
    private lazy var creditCardButton = cell("Tarjeta de crédito")
    
    func tapCreditCardOption() -> CardScreen{
        creditCardButton.tap()
        return CardScreen()
    }
    override func waitForElements() {
        waitFor(element: creditCardButton)
    }
}

class CashOptionsScreen: BaseScreen {
    private lazy var rapipagoButton = cell("Rapipago")
    
    func tapRapipagoOption() -> ReviewScreen{
        rapipagoButton.tap()
        return ReviewScreen()
    }
    override func waitForElements() {
        waitFor(element: rapipagoButton)
    }
}

