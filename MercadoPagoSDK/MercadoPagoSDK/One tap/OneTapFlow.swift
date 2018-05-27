//
//  OneTapFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
final class OneTapFlow: PXFlow {

    let viewModel: OneTapFlowViewModel
    let pxNavigationHandler: PXNavigationHandler
    let finishOneTapCallback: ((PaymentData) -> Void)
    let cancelOneTapCallback: (() -> Void)
    let exitCheckoutCallback: (() -> Void)

    init(navigationController: PXNavigationHandler, paymentData: PaymentData, checkoutPreference: CheckoutPreference, search: PaymentMethodSearch, paymentOptionSelected: PaymentMethodOption, reviewScreenPreference: ReviewScreenPreference, finishOneTap: @escaping ((PaymentData) -> Void), cancelOneTap: @escaping (() -> Void), exitCheckout: @escaping (() -> Void)) {
        pxNavigationHandler = navigationController
        finishOneTapCallback = finishOneTap
        cancelOneTapCallback = cancelOneTap
        exitCheckoutCallback = exitCheckout
        viewModel = OneTapFlowViewModel(paymentData: paymentData, checkoutPreference: checkoutPreference, search: search, paymentOptionSelected: paymentOptionSelected, reviewScreenPreference: reviewScreenPreference)
    }

    deinit {
        #if DEBUG
            print("DEINIT FLOW - \(self)")
        #endif
    }

    func start() {
        executeNextStep()
    }

    func executeNextStep() {
        switch self.viewModel.nextStep() {
        case .screenReviewOneTap:
            self.showReviewAndConfirmScreenForOneTap()
        case .screenSecurityCode:
            self.showSecurityCodeScreen()
        case .serviceCreateESCCardToken:
            self.createCardToken()
        case .finish:
            self.finishFlow()
        }
    }

    // Cancel one tap and go to checkout
    func cancelFlow() {
        cancelOneTapCallback()
    }

    // Finish one tap and continue with checkout
    func finishFlow() {
        finishOneTapCallback(viewModel.paymentData)
    }

    // Exit checkout
    func exitCheckout() {
        exitCheckoutCallback()
    }
}

extension OneTapFlow {
    /// Returns a auto selected payment option from a paymentMethodSearch object. If no option can be selected it returns nil
    ///
    /// - Parameters:
    ///   - search: payment method search item
    ///   - paymentMethodPlugins: payment Methods plugins that can be show
    /// - Returns: selected payment option if possible
    static func autoSelectOneTapOption(search: PaymentMethodSearch, paymentMethodPlugins: [PXPaymentMethodPlugin], forceTest: Bool = false) -> PaymentMethodOption? {

        if forceTest {
            return MockPaymentOption()
        }

        var selectedPaymentOption: PaymentMethodOption?
        if search.hasCheckoutDefaultOption() {
            // Check if can autoselect plugin
            let paymentMethodPluginsFound = paymentMethodPlugins.filter { (paymentMethodPlugin: PXPaymentMethodPlugin) -> Bool in
                return paymentMethodPlugin.getId() == search.oneTap?.getPaymentOptionId()
            }
            if let paymentMethodPlugin = paymentMethodPluginsFound.first {
                selectedPaymentOption = paymentMethodPlugin
            } else {
                // Check if can autoselect customer card
                let customOptionsFound = search.customerPaymentMethods!.filter { (cardInformation: CardInformation) -> Bool in
                    return cardInformation.getCardId() == search.oneTap?.getPaymentOptionId()
                }
                if let customerPaymentOption = customOptionsFound.first as? PaymentMethodOption {
                    if search.oneTap?.oneTapCard?.getSelectedPayerCost() != nil {
                        selectedPaymentOption = customerPaymentOption
                    }
                }}
        }
        return selectedPaymentOption
    }
}

// TODO: Only for test flow. Remove before merge.
class MockPaymentOption: PaymentMethodOption {

    func getId() -> String {
        return "rapipago"
    }

    func getDescription() -> String {
        return "Rapipago mocked payment method"
    }

    func getComment() -> String {
        return ""
    }

    func hasChildren() -> Bool {
        return false
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func isCard() -> Bool {
        return false
    }

    func isCustomerPaymentMethod() -> Bool {
        return false
    }
}
