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
  
    func testCreditCardFlow() {
        MainScreen()
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
    
    func testPaymentMethodOff() {
        MainScreen()
            .tapCheckoutOption()
            .tapCashOption()
            .tapRapipagoOption()
            .tapPayButton()
        
    }
    
    
}
