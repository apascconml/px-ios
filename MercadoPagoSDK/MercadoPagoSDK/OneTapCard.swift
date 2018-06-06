//
//  OneTapCard.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
open class OneTapCard: NSObject {
    open var cardId: String
    open var cardDescription: String?
    open var issuer: Issuer?
    open var lastFourDigits: String?
    open var installments: Int
    open var payerCosts: [PayerCost]?

    public init(cardId: String, cardDescription: String?, issuer: Issuer?, lastFourDigits: String?, installments: Int, payerCosts: [PayerCost]?) {
        self.cardId = cardId
        self.cardDescription = cardDescription
        self.issuer = issuer
        self.lastFourDigits = lastFourDigits
        self.installments = installments
        self.payerCosts = payerCosts
    }
}

extension OneTapCard {
    func getSelectedPayerCost() -> PayerCost? {
        guard let payerCosts = payerCosts else {
            return nil
        }
        let selectedPayerCost = payerCosts.filter {$0.installments == installments}
        return selectedPayerCost.first
    }
}
