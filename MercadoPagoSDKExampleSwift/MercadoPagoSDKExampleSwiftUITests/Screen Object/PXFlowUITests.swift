//
//  PXFlowUITests.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

class PXFlowUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStartCheckout() {
        MainScreen()
            .fillPublicKey("APP_USR-648a260d-6fd9-4ad7-9284-90f22262c18d")
            .fillPreferenceId("243966003-d0be0be0-6fd8-4769-bf2f-7f2d979655f5")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("4242 4242 4242 4242")
            .completeNameAndContinue("Juan Sanzone")
            .completeExpirationDateAndContinue("1122")
            .completeCVVAndContinue("123")
            .completeNumberAndContinue("30666777")
            .selectFirstOption()
            .tapPayButton()
    }
  
    func testCreditCardFlow() {
        MainScreen()
            .tapCheckoutOption().validate(validationAssets: {
                (groupsScreen) in
                    groupsScreen.waitFor(element: groupsScreen.cell("Pago en efectivo"))
            })
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("4242 4242 4242 4242")
            .completeNameAndContinue("Juan Sanzone")
            .completeExpirationDateAndContinue("1122")
            .completeCVVAndContinue("123")
            .completeNumberAndContinue("30666777")
            .selectFirstOption()
            .tapPayButton()
    }
    
    func testPaymentMethodOff() {
        MainScreen()
            .tapCheckoutOption()
            .tapCashOption()
            .tapRapipagoOption()
            .tapPayButton()
        
    }
    
    
}
