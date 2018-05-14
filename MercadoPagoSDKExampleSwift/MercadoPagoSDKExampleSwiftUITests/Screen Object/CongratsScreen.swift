//
//  CongratsScreen.swift
//  PXFlowUITests
//
//  Created by Demian Tejo on 21/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class CongratsScreen: BaseScreen {
    override func waitForElements() {
        
    }
//
//    func waitForAnyCongrats() -> CongratsScreen {
////        let instructionsFooterButton = cellButton("Continuar")
////        waitFor(element: instructionsFooterButton)
//        return self
//    }
//
//    func waitForApprovedCongrats() -> CongratsScreen {
//        let instructionsFooterButton = cellButton("Continuar")
//        waitFor(element: instructionsFooterButton)
//        return self
//    }
//
//    func waitForRejectedCongrats() -> CongratsScreen {
//        let instructionsFooterButton = cellButton("Pagar con otro medio")
//        waitFor(element: instructionsFooterButton)
//        return self
//    }
//
//    func waitForInstructionsCongrats() -> CongratsScreen {
//        let instructionsFooterButton = cellButton("Continuar")
//        waitFor(element: instructionsFooterButton)
//        return self
//    }
}

class ApprovedScreen: CongratsScreen {
    override func waitForElements() {

    }
}

class RejectedScreen: CongratsScreen {
    private lazy var subtitleLabel = element("Continuar")
    override func waitForElements() {
        waitFor(element: subtitleLabel)
    }
}

class PendingScreen: CongratsScreen {
    override func waitForElements() {

    }
}

class InstructionsScreen: CongratsScreen {
    private lazy var instructionsFooterButton = element("Continuar")
    override func waitForElements() {
        waitFor(element: instructionsFooterButton)
    }
}

