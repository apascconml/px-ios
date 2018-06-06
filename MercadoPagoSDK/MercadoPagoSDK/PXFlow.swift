//
//  PXFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 15/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
protocol PXFlow {
    var pxNavigationHandler: PXNavigationHandler { get }

    // Step logic
    func start()
    func executeNextStep()

    // Exit flow
    func cancelFlow()
    func finishFlow()
    func exitCheckout()
}

protocol PXFlowModel {
    associatedtype Steps
    func nextStep() -> Steps
}
