//
//  OneTapFlowTests.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

import XCTest

class OneTapFlowTests: BaseTest {

    var mpCheckout: MercadoPagoCheckout!

    func testMercadoPagoCheckout_oneTapCanAutoSelect() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "account_money", name: "account_money 1", configPaymentMethodPlugin: nil)
        let accountMoneyPaymentMethod = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        let paymentDataAccountMoney = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPaymentMethod)

        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

        mpCheckout.setPaymentMethodPlugins(plugins: [mockPaymentMethodPlugin1])

        XCTAssertNotNil(mpCheckout.viewModel)

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        MPCheckoutTestAction.loadGroupsWithOneTapInViewModel(mpCheckout: mpCheckout)

        // 4. Flow one tap
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FLOW_ONE_TAP, step)

        // 4. Payment plugin
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataAccountMoney)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_PLUGIN_PAYMENT, step)

        // 6. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 6. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testMercadoPagoCheckout_oneTapCanNOTAutoSelect() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "account_money_not", name: "account_money 1", configPaymentMethodPlugin: nil)
        let accountMoneyPaymentMethod = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        let paymentDataAccountMoney = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPaymentMethod)

        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

        mpCheckout.setPaymentMethodPlugins(plugins: [mockPaymentMethodPlugin1])

        XCTAssertNotNil(mpCheckout.viewModel)

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        MPCheckoutTestAction.loadGroupsWithOneTapInViewModel(mpCheckout: mpCheckout)

        // 4. Payment Method Selection Screen
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 4. Post Payment
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataAccountMoney)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 6. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 6. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

}
