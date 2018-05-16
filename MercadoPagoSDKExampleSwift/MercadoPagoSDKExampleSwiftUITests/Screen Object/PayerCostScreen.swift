//
//  PayerCostScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 16/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PayerCostScreen: BaseScreen {

    private lazy var headerCellCount = 2
    private lazy var backButton = getBackButton()
    
    override func waitForElements() {
        waitFor(element: cellNumber(3))
    }

    func selectPayerCostOptionAtRow(_ rowNumber: Int) -> ReviewScreen {
        tapRow(number: rowNumber)
        return ReviewScreen()
    }

    func tapRow(number: Int) {
        let payerCostCell = cellNumber(headerCellCount + number)
        payerCostCell.tap()
    }

    func tapBackButtonToIssuersScreen() -> IssuersScreen {
        backButton.tap()
        return IssuersScreen()
    }

    func tapBackButtonToIdentificationScreen() -> IdentificationScreen {
        backButton.tap()
        return IdentificationScreen()
    }
}
