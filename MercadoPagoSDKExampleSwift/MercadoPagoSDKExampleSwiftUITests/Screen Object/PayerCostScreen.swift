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
    
    override func waitForElements() {
        waitFor(element: cellNumber(3))
    }

    func selectPayerCostOptionAtRow(_ rowNumber: Int) -> ReviewScreen {
        let payerCostCell = cellNumber(headerCellCount + rowNumber)
        payerCostCell.tap()
        return ReviewScreen()
    }
}
