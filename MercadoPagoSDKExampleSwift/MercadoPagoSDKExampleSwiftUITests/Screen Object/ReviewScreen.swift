//
//  ReviewScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 16/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class ReviewScreen: BaseScreen {
    private lazy var payButton = cellButton("Confirmar")
    
    override func waitForElements() {
        waitFor(element: payButton)
    }
    
    func tapPayButton()  -> CongratsScreen{
        payButton.tap()
        return CongratsScreen()
    }
}
