//
//  PaymentFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal final class PXPaymentFlow: NSObject, PXFlow {

    let model: PXPaymentFlowModel

    weak var resultHandler: PXPaymentResultHandlerProtocol?
    weak var paymentErrorHandler: PXPaymentErrorHandlerProtocol?

    var pxNavigationHandler: PXNavigationHandler

    init(paymentPlugin: PXPaymentPluginComponent?, paymentMethodPaymentPlugin: PXPaymentPluginComponent?, binaryMode: Bool, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, paymentErrorHandler: PXPaymentErrorHandlerProtocol, navigationHandler: PXNavigationHandler) {
        model = PXPaymentFlowModel(paymentPlugin: paymentPlugin, paymentMethodPaymentPlugin: paymentMethodPaymentPlugin, binaryMode: binaryMode, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
        self.paymentErrorHandler = paymentErrorHandler
        self.pxNavigationHandler = navigationHandler
    }

    func setData(paymentData: PaymentData, checkoutPreference: CheckoutPreference, resultHandler: PXPaymentResultHandlerProtocol) {
        self.model.paymentData = paymentData
        self.model.checkoutPreference = checkoutPreference
        self.resultHandler = resultHandler
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
        switch self.model.nextStep() {
        case .createDefaultPayment:
            createPayment()
        case .createPaymentMethodPaymentPlugin:
            createPaymentWithPlugin(plugin: model.paymentMethodPaymentPlugin)
        case .createPaymentPlugin:
            createPaymentWithPlugin(plugin: model.paymentPlugin)
        case .createPaymentPluginScreen:
            showPaymentPluginComponent(paymentPluginComponent: model.paymentPlugin)
        case .createPaymentMethodPaymentPluginScreen:
            showPaymentPluginComponent(paymentPluginComponent: model.paymentMethodPaymentPlugin)
        case .getInstructions:
            getInstructions()
        case .finish:
            finishFlow()
        }
    }

    func getPaymentTimeOut() -> TimeInterval {
        let instructionTimeOut: TimeInterval = model.isOfflinePayment() ? 15 : 0
        if let paymentPluginTimeOut = model.paymentPlugin?.paymentTimeOut?() {
            return paymentPluginTimeOut + instructionTimeOut
        } else if let paymentMethodPluginTimeOut = model.paymentMethodPaymentPlugin?.paymentTimeOut?() {
            return paymentMethodPluginTimeOut + instructionTimeOut
        } else {
            return model.mercadoPagoServicesAdapter.getTimeOut() + instructionTimeOut
        }
    }

    func finishFlow() {
        if let paymentResult = model.paymentResult {
            self.resultHandler?.finishPaymentFlow(paymentResult: (paymentResult), instructionsInfo: model.instructionsInfo)
        } else if let businessResult = model.businessResult {
            self.resultHandler?.finishPaymentFlow(businessResult: businessResult)
        }
    }

    func cancelFlow() {}

    func exitCheckout() {}

    fileprivate func showPaymentPluginComponent(paymentPluginComponent: PXPaymentPluginComponent?) {
        guard let paymentPluginComponent = paymentPluginComponent else {
            return
        }

        let containerVC = MercadoPagoUIViewController()

        // By feature definition. Back is not available in make payment plugin.
        containerVC.shouldShowBackArrow = false

        model.assignToCheckoutStore()
        paymentPluginComponent.didReceive?(pluginStore: PXCheckoutStore.sharedInstance)

        // Create navigation handler.
        paymentPluginComponent.navigationHandlerForPaymentPlugin?(navigationHandler: PXPaymentPluginNavigationHandler(flow: self))

        if let navTitle = paymentPluginComponent.titleForNavigationBar?() {
            containerVC.title = navTitle
        }

        if let navBarColor = paymentPluginComponent.colorForNavigationBar?() {
            containerVC.setNavBarBackgroundColor(color: navBarColor)
        }

        if let shouldShowNavigationBar = paymentPluginComponent.shouldShowNavigationBar?() {
            containerVC.shouldHideNavigationBar = !shouldShowNavigationBar
        }

        if let paymentPluginComponentView = paymentPluginComponent.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
            paymentPluginComponentView.removeFromSuperview()
            paymentPluginComponentView.frame = containerVC.view.frame
            paymentPluginComponentView.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
            containerVC.view.addSubview(paymentPluginComponentView)
        }

        //TODO: Change in Q2 - Payment processor by block. Not a view.
        containerVC.view.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
        paymentPluginComponent.renderDidFinish?()

        self.pxNavigationHandler.navigationController.pushViewController(containerVC, animated: false)
    }

}

extension PXPaymentFlow: PXPaymentFlowHandlerProtocol {
    public func showErrorScreen(message: String, errorDetails: String, retry: Bool = true) {
        let error = MPSDKError(message: message, errorDetail: errorDetails, retry: retry)
        resultHandler?.finishPaymentFlow(error: error)
    }

    func showErrorScreen(error: MPSDKError) {
        resultHandler?.finishPaymentFlow(error: error)
    }
}
