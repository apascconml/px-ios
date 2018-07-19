//
//  PXPaymentFlowHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
@objc public protocol PXPaymentFlowHandlerProtocol: NSObjectProtocol {
    @objc func showErrorScreen(message: String, errorDetails: String, retry: Bool)
}
