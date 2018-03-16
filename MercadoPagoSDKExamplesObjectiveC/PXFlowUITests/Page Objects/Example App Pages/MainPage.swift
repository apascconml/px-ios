//
//  MainScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class MainScreen: BaseScreen {

    private lazy var checkoutButton = cell("Checkout")
    

    func tapCheckoutOption() -> MainGroupScreen {
        checkoutButton.tap()
        let mainGroupScreen = MainGroupScreen()
        return mainGroupScreen
    }
    
    override func waitForElements() {
        waitFor(element: checkoutButton)
    }

    
}
