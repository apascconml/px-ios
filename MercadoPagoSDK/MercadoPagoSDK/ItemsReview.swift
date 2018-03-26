//
//  ItemsReview.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class ItemsReview: NSObject {
    var quantityTitle: String = "Productos".localized_temp
    var amountTitle: String = PXStrings.unit_price_string.pxLocalized
    var showQuantityRow: Bool = true
    var showAmountTitle: Bool = true
}
