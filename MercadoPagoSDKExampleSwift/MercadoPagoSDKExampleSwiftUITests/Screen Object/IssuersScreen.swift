//
//  IssuersScreen.swift
//  MercadoPagoSDKExampleSwiftUITests
//
//  Created by AUGUSTO COLLERONE ALFONSO on 2/5/18.
//  Copyright © 2018 Mercado Pago. All rights reserved.
//

import UIKit

class IssuersScreen: BaseScreen {

    private lazy var issuer1 = cellNumber(5)

    override func waitForElements() {
        waitFor(element: issuer1)
    }

    func selectToPayerCostOptionAt(_ row: Int) -> PayerCostScreen {
        let issuerCell = cellNumber(row)
        issuerCell.tap()
        return PayerCostScreen()
    }

    func selectToReviewOptionAt(_ row: Int) -> ReviewScreen {
        let issuerCell = cellNumber(row)
        issuerCell.tap()
        return ReviewScreen()
    }

    func selectFirstOption() -> PayerCostScreen {
        issuer1.tap()
        return PayerCostScreen()
    }
}

