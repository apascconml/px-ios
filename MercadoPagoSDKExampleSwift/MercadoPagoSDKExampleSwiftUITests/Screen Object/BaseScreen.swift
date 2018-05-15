//
//  BaseScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest
import UIKit

protocol BaseScreenProtocol {
    func waitForElements()
}

class BaseScreen : BaseScreenProtocol {
    let TIME_OUT : Double = 5 // Seconds
    init() {
        waitForElements()
    }
    
    func validate(validationAssets:((BaseScreen)->Void)) -> Self {
        validationAssets(self)
        return self
    }

    internal func waitForElements() {
         fatalError("All Screens Must Override this Method")
    }

    func exist(element : XCUIElement) -> Bool{
        let exists = NSPredicate(format: "exists = 1")
        return element.exists
    }
}

// MARK: Loading screen helpers
extension BaseScreen {
    func waitForExpectation(expectation:XCTestExpectation,
                            time: Double,
                            safe: Bool = false) {
        let result: XCTWaiter.Result =
            XCTWaiter().wait(for: [expectation],
                             timeout: time)
        if !safe && result != .completed {
            XCTFail("Condition was not satisfied during \(time) seconds")
        }
    }
    
    func waitFor(element : XCUIElement){
        let exists = NSPredicate(format: "exists = 1")
        self.waitForExpectation(expectation: XCTNSPredicateExpectation(predicate: exists, object: element), time: TIME_OUT)
    }
}

// MARK: Take elements from screen
extension BaseScreen {
    func findAll(_ type: XCUIElement.ElementType) -> XCUIElementQuery {
        return XCUIApplication().descendants(matching: type)
    }
    func cell(_ text: String) -> XCUIElement {
        return findAll(.cell).containing(.staticText, identifier: text).element
    }
    func textField(_ text: String) -> XCUIElement {
        return  XCUIApplication().textFields[text]
    }
    func toolbarButton(_ text: String) -> XCUIElement {
        return XCUIApplication().toolbars.buttons[text]
    }
    func cellNumber(_ row : Int)  -> XCUIElement{
        return  XCUIApplication().cells.allElementsBoundByIndex[row]
        
    }
    func cellButton(_ text: String) -> XCUIElement {
        return button(text)
    }
    func button(_ text: String) -> XCUIElement {
        return XCUIApplication().buttons[text].firstMatch
    }
    func element(_ text: String) -> XCUIElement {
        return XCUIApplication().staticTexts[text].firstMatch
    }
}
