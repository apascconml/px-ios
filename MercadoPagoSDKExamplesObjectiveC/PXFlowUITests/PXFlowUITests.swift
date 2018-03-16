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
           // .selectFirstOption()
        
        let app = XCUIApplication()
        app.statusBars.otherElements["-100% battery power"].tap()
        app.otherElements["Loading"].tap()
        
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Tarjetas").children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Tarjeta de crédito").children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.textFields["Número de tarjeta"].tap()
        app.textFields["Nombre y apellido"].typeText("4")
        
        let fechaDeExpiraciNTextField = app.textFields["Fecha de expiración"]
        fechaDeExpiraciNTextField.tap()
        fechaDeExpiraciNTextField.typeText("2")
        fechaDeExpiraciNTextField.tap()
        
        let cDigoDeSeguridadTextField = app.textFields["Código de seguridad"]
        cDigoDeSeguridadTextField.typeText("4")
        cDigoDeSeguridadTextField.tap()
        cDigoDeSeguridadTextField.typeText("2")
        cDigoDeSeguridadTextField.tap()
        cDigoDeSeguridadTextField.typeText("42")
        cDigoDeSeguridadTextField.tap()
        cDigoDeSeguridadTextField.typeText("4")
        cDigoDeSeguridadTextField.tap()
        cDigoDeSeguridadTextField.tap()
        app.typeText("2")
        
        let nMeroTextField = app.textFields["Número"]
        nMeroTextField.typeText("4")
        nMeroTextField.tap()
        nMeroTextField.tap()
        nMeroTextField.typeText("24")
        nMeroTextField.tap()
        nMeroTextField.typeText("24")
        nMeroTextField.tap()
        nMeroTextField.typeText("2")
        nMeroTextField.tap()
        nMeroTextField.typeText("4")
        nMeroTextField.tap()
        nMeroTextField.typeText("24")
        app.typeText("2424")
        
    }
    
}
