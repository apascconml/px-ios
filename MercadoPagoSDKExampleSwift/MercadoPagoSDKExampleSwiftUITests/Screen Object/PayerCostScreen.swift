//
//  PayerCostScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 16/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PayerCostScreen: BaseScreen {

     private lazy var payerCost1 = cellNumber(5)
    
    override func waitForElements() {
        waitFor(element: payerCost1)
    }
    func selectFirstOption() -> ReviewScreen{
        payerCost1.tap()
        return ReviewScreen()
    }
}
