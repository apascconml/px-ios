//
//  MercadopagoCheckoutLifecycleProtocol.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objc public protocol PXCheckoutLifecycleProtocol: NSObjectProtocol {
    func lazyInitDidFinish()
    func lazyInitFailure(errorDetail: String)
}
