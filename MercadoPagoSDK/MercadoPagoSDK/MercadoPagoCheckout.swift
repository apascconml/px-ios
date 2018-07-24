//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTrackingV4
import MercadoPagoServicesV4

@objcMembers
open class MercadoPagoCheckout: NSObject {

    enum InitMode {
        case normal
        case lazy
    }

    // Init
    var initMode: InitMode = .normal
    var lifecycleProtocol: PXCheckoutLifecycleProtocol?

    static var currentCheckout: MercadoPagoCheckout?
    var viewModel: MercadoPagoCheckoutViewModel

    public init(publicKey: String, accessToken: String, checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, navigationController: UINavigationController) {

        MercadoPagoCheckoutViewModel.flowPreference.removeHooks()

        MercadoPagoContext.setPublicKey(publicKey)
        MercadoPagoContext.setPayerAccessToken(accessToken)

        ThemeManager.shared.initialize()

        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, navigationHandler: PXNavigationHandler(navigationController: navigationController))

        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)

        MercadoPagoCheckoutViewModel.flowPreference.disableESC()
    }

    public func setTheme(_ theme: PXTheme) {
        ThemeManager.shared.setTheme(theme: theme)
    }

    public func setDefaultColor(_ color: UIColor) {
        ThemeManager.shared.setDefaultColor(color: color)
    }

    func initMercadPagoPXTracking() {
        MPXTracker.setPublicKey(MercadoPagoContext.sharedInstance.publicKey())
        MPXTracker.setSdkVersion(MercadoPagoContext.sharedInstance.sdkVersion())
        MPXTracker.sharedInstance.startNewFlow()
    }

    public func setBinaryMode(_ binaryMode: Bool) {
        self.viewModel.binaryMode = binaryMode
    }

    public func start() {
        
        if initMode == .lazy {
            if viewModel.initFlow?.getStatus() == .finished {
                executeNextStep()
            } else {
                if viewModel.initFlow?.getStatus() == .running {
                    return
                } else {
                    // Lazy with "ready" to run.
                    viewModel.pxNavigationHandler.presentInitLoading()
                    executeNextStep()
                }
            }
        } else {
            viewModel.pxNavigationHandler.presentInitLoading()
            executeNextStep()
        }
    }

    public func lazyStart(lifecycleDelegate: PXCheckoutLifecycleProtocol) {
        viewModel.initFlow?.restart()
        lifecycleProtocol = lifecycleDelegate
        initMode = .lazy
        executeNextStep()
    }

    private func commonInit() {
        viewModel.setInitFlowProtocol(flowInitProtocol: self)
        if !shouldApplyDiscount() {
            viewModel.clearDiscount()
        }
    }

    public func setPaymentResult(paymentResult: PaymentResult) {
        self.viewModel.paymentResult = paymentResult
    }

    public func setCheckoutPreference(checkoutPreference: CheckoutPreference) {
        self.viewModel.checkoutPreference = checkoutPreference
    }

    public func setPaymentData(paymentData: PaymentData) {
        self.viewModel.paymentData = paymentData
    }

    public func setPaymentMethodPlugins(plugins: [PXPaymentMethodPlugin]) {
        viewModel.paymentMethodPlugins = plugins
        viewModel.paymentMethodPluginsToShow = plugins
        viewModel.updateInitFlow()
    }

    public func getPXCheckoutStore() -> PXCheckoutStore {
        viewModel.populateCheckoutStore()
        return PXCheckoutStore.sharedInstance
    }

    public func setPaymentPlugin(paymentPlugin: PXPaymentPluginComponent) {
        viewModel.paymentPlugin = paymentPlugin
        viewModel.updateInitFlow()
    }

    public func resume() {
        MercadoPagoCheckout.currentCheckout = self
        executeNextStep()
    }

    func executePreviousStep(animated: Bool = true) {
        viewModel.pxNavigationHandler.navigationController.popViewController(animated: animated)
    }

    private func initialize() {
        commonInit()
        initMercadPagoPXTracking()
        MercadoPagoCheckout.currentCheckout = self
        viewModel.pxNavigationHandler.suscribeToNavigationFlow()
        if let currentCheckout = MercadoPagoCheckout.currentCheckout {
            PXNotificationManager.SuscribeTo.attemptToClose(currentCheckout, selector: #selector(closeCheckout))
        }
        viewModel.startInitFlow()
    }

    func executeNextStep() {
        switch self.viewModel.nextStep() {
        case .START :
            self.initialize()
        case .SCREEN_PAYMENT_METHOD_SELECTION:
            self.showPaymentMethodsScreen()
        case .SCREEN_CARD_FORM:
            self.showCardForm()
        case .SCREEN_IDENTIFICATION:
            self.showIdentificationScreen()
        case .SCREEN_PAYER_INFO_FLOW:
            self.showPayerInfoFlow()
        case .SCREEN_ENTITY_TYPE:
            self.showEntityTypesScreen()
        case .SCREEN_FINANCIAL_INSTITUTIONS:
            self.showFinancialInstitutionsScreen()
        case .SERVICE_GET_ISSUERS:
            self.getIssuers()
        case .SCREEN_ISSUERS:
            self.showIssuersScreen()
        case .SERVICE_CREATE_CARD_TOKEN:
            self.createCardToken()
        case .SERVICE_GET_IDENTIFICATION_TYPES:
            self.getIdentificationTypes()
        case .SERVICE_GET_PAYER_COSTS:
            self.getPayerCosts()
        case .SCREEN_PAYER_COST:
            self.showPayerCostScreen()
        case .SCREEN_REVIEW_AND_CONFIRM:
            self.showReviewAndConfirmScreen()
        case .SCREEN_SECURITY_CODE:
            self.showSecurityCodeScreen()
        case .SERVICE_POST_PAYMENT:
            self.createPayment()
        case .SCREEN_PAYMENT_RESULT:
            self.showPaymentResultScreen()
        case .ACTION_FINISH:
            self.finish()
        case .SCREEN_ERROR:
            self.showErrorScreen()
        case .SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG:
            self.showHookScreen(hookStep: .BEFORE_PAYMENT_METHOD_CONFIG)
        case .SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG:
            self.showHookScreen(hookStep: .AFTER_PAYMENT_METHOD_CONFIG)
        case .SCREEN_HOOK_BEFORE_PAYMENT:
            self.showHookScreen(hookStep: .BEFORE_PAYMENT)
        case .SCREEN_PAYMENT_METHOD_PLUGIN_PAYMENT:
            self.showPaymentMethodPluginPaymentScreen()
        case .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG:
            self.showPaymentMethodPluginConfigScreen()
        case .SCREEN_PAYMENT_PLUGIN_PAYMENT: //PROCESADORA
            self.showPaymentPluginScreen()
        case .FLOW_ONE_TAP:
            self.startOneTapFlow()
        default: break
        }
    }

    private func executePaymentDataCallback() {
        if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
        }
    }

    func finish() {
        viewModel.pxNavigationHandler.removeRootLoading()

        if self.viewModel.paymentData.isComplete() && !MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataCallback != nil && !self.viewModel.isCheckoutComplete() {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
            return

        } else if self.viewModel.paymentData.isComplete() && MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil && !self.viewModel.isCheckoutComplete() {
            MercadoPagoCheckoutViewModel.paymentDataConfirmCallback!(self.viewModel.paymentData)
            return

        } else if let payment = self.viewModel.payment, let paymentCallback = MercadoPagoCheckoutViewModel.paymentCallback {
            paymentCallback(payment)
            return

        } else if let finishFlowCallback = MercadoPagoCheckoutViewModel.finishFlowCallback {
            finishFlowCallback(self.viewModel.payment)
            return
        }
        viewModel.pxNavigationHandler.goToRootViewController()
    }

    func cancel() {
        if let callback = viewModel.callbackCancel {
            callback()
            return
        }
        viewModel.pxNavigationHandler.goToRootViewController()
    }
    @objc func closeCheckout() {
        PXNotificationManager.UnsuscribeTo.attemptToClose(self)
        cancel()
    }

    public func popToWhenFinish(viewController: UIViewController) {
        viewModel.pxNavigationHandler.popToWhenFinish(viewController: viewController)
    }

    public func setDiscount(_ discount: PXDiscount, withCampaign campaign: PXCampaign) {
        viewModel.setDiscount(discount, withCampaign: campaign)
          self.viewModel.setDiscount(discount, withCampaign: campaign)
    }

    public func setChargeRules(chargeRules: [PXPaymentTypeChargeRule]) {
        viewModel.chargeRules = chargeRules
    }

    private func shouldApplyDiscount() -> Bool {
        return self.viewModel.paymentPlugin != nil
    }
}
