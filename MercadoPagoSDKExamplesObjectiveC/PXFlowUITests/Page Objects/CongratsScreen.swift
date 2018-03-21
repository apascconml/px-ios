//
//  CongratsScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 21/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class CongratsScreen: BaseScreen {
    private lazy var payButton = cellButton("Pagar")
    
    override func waitForElements() {
        waitFor(element: payButton)
    }
}
