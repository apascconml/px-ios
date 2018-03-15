//
//  BaseScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 12/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import XCTest

protocol BaseScreenProtocol {
    func waitForElements()
}

class BaseScreen : BaseScreenProtocol {
    
    init() {
        waitForElements()
    }
    
    func waitForElements() {
        
    }
    func findAll(_ type: XCUIElement.ElementType) -> XCUIElementQuery {
        return XCUIApplication().descendants(matching: type)
    }
    func waitForExpectation(expectation:XCTestExpectation,
                            time: Double,
                            safe: Bool = false) {
        let result: XCTWaiter.Result =
            XCTWaiter().wait(for: [expectation],
                             timeout: time)
        if !safe && result != .completed {
            // if expectation is strict and was not fulfilled
            XCTFail("Condition was not satisfied during \(time) seconds")
        }
    }
    
    func waitFor(element : XCUIElement){
        let exists = NSPredicate(format: "exists = 1")
         self.waitForExpectation(expectation: XCTNSPredicateExpectation(predicate: exists, object: element), time: 5)
    }
    
    func cellWith(text: String) -> XCUIElement {
        return findAll(.cell).containing(.staticText, identifier: text).element
    }
}
