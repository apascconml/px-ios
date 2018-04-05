//
//  PXResultConstants.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// MARK: Header Constants
struct PXHeaderResultConstants {

    // Header titles
    static let APPROVED_HEADER_TITLE = PXStrings.success_payment_title
    static let PENDING_HEADER_TITLE = "Estamos procesando el pago"
    static let REJECTED_HEADER_TITLE = "Uy, no pudimos procesar el pago"

    // Icon subtext
    static let REJECTED_ICON_SUBTEXT = PXStrings.error_header_title

}
// MARK: Footer Constants
struct PXFooterResultConstants {

    // Button texts
    static let ERROR_BUTTON_TEXT = PXStrings.use_other_payment_method_action
    static let C4AUTH_BUTTON_TEXT = PXStrings.use_other_payment_method_action
    static let CARD_DISABLE_BUTTON_TEXT = "Ya habilité mi tarjeta"
    static let WARNING_BUTTON_TEXT = "Revisar los datos de tarjeta"
    static let DEFAULT_BUTTON_TEXT: String? = nil

    // Link texts
    static let APPROVED_LINK_TEXT = PXStrings.payment_result_screen_congrats_finish_button
    static let ERROR_LINK_TEXT = PXStrings.cancel_payment_action
    static let C4AUTH_LINK_TEXT = PXStrings.cancel_payment_action
    static let WARNING_LINK_TEXT = PXStrings.use_other_payment_method_action
    static let DEFAULT_LINK_TEXT = PXStrings.payment_result_screen_congrats_finish_button
}
