//
//  SummaryItemDetail.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

@objc open class SummaryItemDetail: NSObject {
    var name: String?
    var amount: Double
    public init(name: String? = nil, amount: Double) {
        self.name = name
        self.amount = amount
    }
}
