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

    func test_REGRESSION_ETE1() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-648a260d-6fd9-4ad7-9284-90f22262c18d")
            .fillPreferenceId("243966003-d0be0be0-6fd8-4769-bf2f-7f2d979655f5")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("5323 7937 3550 6106")
            .completeNameAndContinue("APRO")
            .completeExpirationDateAndContinue("1225")
            .completeCVVAndContinue("123")
            .completeNumberAndContinueToIssuers("30666777")
            .selectFirstOption()
            .selectFirstOption()
            .tapPayButtonForAnyCongrats()
    }

    func test_REGRESSION_ETE3() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-0d933ff3-b803-4999-a211-8b3c7d5c7c03")
            .fillPreferenceId("243966003-faedce8f-ee83-40a7-b8e6-bba34928383d")
            .tapCheckoutOption()
            .tapCashOption()
            .tapRapipagoOption()
            .tapPayButtonForInstructions()
    }

    func test_REGRESSION_ETE5() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-0d933ff3-b803-4999-a211-8b3c7d5c7c03")
            .fillPreferenceId("243966003-0e1df452-28e3-4d72-8b69-a71123b8a626")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("5323 7937 3550 6106")
            .completeNameAndContinue("APRO")
            .completeExpirationDateAndContinue("1225")
            .completeCVVAndContinue("123")
            .completeNumberAndContinueToIssuers("30666777")
            .selectToReviewOptionAt(6)
            .tapPayButtonForAnyCongrats()
    }

    func test_REGRESSION_ETE6() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-0d933ff3-b803-4999-a211-8b3c7d5c7c03")
            .fillPreferenceId("243966003-bb8f7422-39c1-4337-81dd-60a88eb787df")
            .tapCheckoutOptionOnlyCard()
            .completeNumberAndContinue("5323 7937 3550 6106")
            .completeNameAndContinue("APRO")
            .completeExpirationDateAndContinue("1225")
            .completeCVVAndContinue("123")
            .completeNumberAndContinueToIssuers("30666777")
            .selectToPayerCostOptionAt(6)
            .selectFirstOption()
            .tapPayButtonForAnyCongrats()
    }

    func test_REGRESSION_ETE7_1() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-0d933ff3-b803-4999-a211-8b3c7d5c7c03")
            .fillPreferenceId("243966003-55f883b7-2cfb-4266-8001-11e081a45797")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("5323 7937 3550 6106")
            .completeNameAndContinue("APRO")
            .completeExpirationDateAndContinue("1225")
            .completeCVVAndContinue("123")
            .completeNumberAndContinueToIssuers("30666777")
            .selectFirstOption()
            .selectFirstOption()
            .tapPayButtonForAnyCongrats()
    }

    func test_REGRESSION_ETE7_2() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-0d933ff3-b803-4999-a211-8b3c7d5c7c03")
            .fillPreferenceId("243966003-55f883b7-2cfb-4266-8001-11e081a45797")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndExpectInvalidFieldError("4509 9535 6623 3704")
            .tapAvailableCardsButton()
    }

    func test_REGRESSION_ETE10() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("TEST-c6d9b1f9-71ff-4e05-9327-3c62468a23ee")
            .fillPreferenceId("243962506-465d2dc6-f83b-4090-be64-8374196a3ab3")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .completeNumberAndContinue("5323 7937 3550 6106")
            .completeNameAndContinue("APRO")
            .completeExpirationDateAndContinue("1225")
            .completeCVVAndContinue("123")
            .completeNumberAndContinueToIssuers("30666777")
            .selectFirstOption()
            .selectFirstOption()
            .tapChangePaymentMethod()
            .tapCashOption()
            .tapRapipagoOption()
            .tapPayButtonForInstructions()
    }

    func test_REGRESSION_ETE12() {
        MainScreen()
            .tapClearButton()
            .fillPublicKey("APP_USR-2681ea61-10af-4bf6-a73d-e426d6b07e2c")
            .fillPreferenceId("243962506-76f3ae80-28de-4c8a-94a5-dad78ef8b4c4")
            .tapCheckoutOption()
            .tapCardOption()
            .tapCreditCardOption()
            .validate(validationAssets: { (cardScreen) in
                XCTAssertTrue(cardScreen.exist(element: cardScreen.element("Solo puedes pagar con Visa")))
            })
    }
}
