//
//  IssuersScreen.swift
//  MercadoPagoSDKExampleSwiftUITests
//
//  Created by AUGUSTO COLLERONE ALFONSO on 2/5/18.
//  Copyright © 2018 Mercado Pago. All rights reserved.
//

import UIKit

class IssuersScreen: BaseScreen {

    private lazy var headerCellCount = 1
    private lazy var backButton = getBackButton()

    override func waitForElements() {
        waitFor(element: cellNumber(3))
    }

    func selectIssuerOptionToPayerCostScreenAtRow(_ rowNumber: Int) -> PayerCostScreen {
        tapRow(number: rowNumber)
        return PayerCostScreen()
    }

    func selectIssuerOptionToReviewScreenAtRow(_ rowNumber: Int) -> ReviewScreen {
        tapRow(number: rowNumber)
        return ReviewScreen()
    }

    func tapRow(number: Int) {
        let issuerCell = cellNumber(headerCellCount + number)
        issuerCell.tap()
    }

    func tapBackButtonToIdentificationScreen() -> IdentificationScreen {
        backButton.tap()
        return IdentificationScreen()
    }
}
