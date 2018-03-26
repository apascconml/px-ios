//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public enum CheckoutStep: String {
    case START
    case ACTION_FINISH
    case ACTION_VALIDATE_PREFERENCE
    case SERVICE_GET_PREFERENCE
    case SERVICE_GET_DIRECT_DISCOUNT
    case SERVICE_GET_PAYMENT_METHODS
    case SERVICE_GET_CUSTOMER_PAYMENT_METHODS
    case SERVICE_GET_IDENTIFICATION_TYPES
    case SCREEN_PAYMENT_METHOD_SELECTION
    case SCREEN_CARD_FORM
    case SCREEN_SECURITY_CODE
    case SERVICE_GET_ISSUERS
    case SCREEN_ISSUERS
    case SERVICE_CREATE_CARD_TOKEN
    case SCREEN_IDENTIFICATION
    case SCREEN_ENTITY_TYPE
    case SCREEN_FINANCIAL_INSTITUTIONS
    case SERVICE_GET_PAYER_COSTS
    case SCREEN_PAYER_INFO_FLOW
    case SCREEN_PAYER_COST
    case SCREEN_REVIEW_AND_CONFIRM
    case SERVICE_POST_PAYMENT
    case SERVICE_GET_INSTRUCTIONS
    case SCREEN_PAYMENT_RESULT
    case SCREEN_ERROR
    case SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG
    case SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG
    case SCREEN_HOOK_BEFORE_PAYMENT
    case SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
    case SCREEN_PAYMENT_METHOD_PLUGIN_PAYMENT
    case SCREEN_PAYMENT_PLUGIN_PAYMENT
    case SERVICE_PAYMENT_METHOD_PLUGIN_INIT
}

open class MercadoPagoCheckoutViewModel: NSObject, NSCopying {

    var startedCheckout = false
    static var servicePreference = ServicePreference()
    static var flowPreference = FlowPreference()
    var reviewScreenPreference = ReviewScreenPreference()
    var paymentResultScreenPreference = PaymentResultScreenPreference()
    static var paymentDataCallback: ((PaymentData) -> Void)?
    static var paymentDataConfirmCallback: ((PaymentData) -> Void)?
    static var paymentCallback: ((Payment) -> Void)?
    static var finishFlowCallback: ((Payment?) -> Void)?
    var callbackCancel: (() -> Void)?
    static var changePaymentMethodCallback: (() -> Void)?

    var checkoutPreference: CheckoutPreference!
    var mercadoPagoServicesAdapter = MercadoPagoServicesAdapter(servicePreference: MercadoPagoCheckoutViewModel.servicePreference)

    //    var paymentMethods: [PaymentMethod]?
    var cardToken: CardToken?
    var customerId: String?

    // Payment methods disponibles en selección de medio de pago
    var paymentMethodOptions: [PaymentMethodOption]?
    var paymentOptionSelected: PaymentMethodOption?
    // Payment method disponibles correspondientes a las opciones que se muestran en selección de medio de pago
    var availablePaymentMethods: [PaymentMethod]?

    var rootPaymentMethodOptions: [PaymentMethodOption]?
    var customPaymentOptions: [CardInformation]?
    var identificationTypes: [IdentificationType]?

    var rootVC = true

    var binaryMode: Bool = false
    var paymentData = PaymentData()
    var payment: Payment?
    var paymentResult: PaymentResult?
    var businessResult: PXBusinessResult?
    
    open var payerCosts: [PayerCost]?
    open var issuers: [Issuer]?
    open var entityTypes: [EntityType]?
    open var financialInstitutions: [FinancialInstitution]?
    open var instructionsInfo: InstructionsInfo?

    static var error: MPSDKError?

    var errorCallback: (() -> Void)?

    var needLoadPreference: Bool = false
    var preferenceValidated: Bool = false
    var readyToPay: Bool = false
    var initWithPaymentData = false
    var directDiscountSearched = false
    var savedESCCardToken: SavedESCCardToken?
    private var checkoutComplete = false
    var paymentMethodConfigPluginShowed = false

    var mpESCManager: MercadoPagoESC = MercadoPagoESCImplementation()

    // Plugins payment method.
    var paymentMethodPlugins = [PXPaymentMethodPlugin]()
    var paymentMethodPluginsToShow = [PXPaymentMethodPlugin]()
    var needPaymentMethodPluginInit = true

    // Payment plguin
    var paymentPlugin: PXPaymentPluginComponent?

    init(checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, discount: DiscountCoupon?) {
        super.init()
        self.checkoutPreference = checkoutPreference
        if let pm = paymentData {
            if pm.isComplete() {
                self.startedCheckout = true
                self.paymentData = pm
                self.directDiscountSearched = true
                if paymentResult == nil {
                    self.initWithPaymentData = true
                } else {
                    if paymentResult!.paymentData != nil && paymentResult!.paymentData!.isComplete() {
                        self.paymentData = paymentResult!.paymentData!
                    }
                    if paymentResult!.isInvalidESC() && pm.hasToken() {
                        self.prepareForInvalidPaymentWithESC()
                    }
                }
            }
        }
        self.paymentResult = paymentResult
        if let discount = discount {
            if paymentData == nil {
                self.paymentData = PaymentData()
            }
            self.paymentData.discount = discount
        }
        if !String.isNullOrEmpty(self.checkoutPreference._id) {
            needLoadPreference = true
        } else {
            self.paymentData.payer = self.checkoutPreference.getPayer()
            MercadoPagoContext.setSiteID(self.checkoutPreference.getSiteId())
        }
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = MercadoPagoCheckoutViewModel(checkoutPreference: self.checkoutPreference, paymentData: self.paymentData, paymentResult: self.paymentResult, discount: self.paymentData.discount)
        return copyObj
    }

    func hasError() -> Bool {
        return MercadoPagoCheckoutViewModel.error != nil
    }

    public func getPaymentPreferences() -> PaymentPreference? {
        return self.checkoutPreference.paymentPreference
    }

    public func cardFormManager() -> CardFormViewModel {
        let paymentPreference = PaymentPreference()
        paymentPreference.defaultPaymentTypeId = self.paymentOptionSelected?.getId()
        // TODO : está bien que la paymentPreference se cree desde cero? puede que vengan exclusiones de entrada ya?
        return CardFormViewModel(paymentMethods: getPaymentMethodsForSelection(), mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    public func getPaymentMethodsForSelection() -> [PaymentMethod] {
        let filteredPaymentMethods = search?.paymentMethods.filter {
            return $0.conformsPaymentPreferences(self.getPaymentPreferences()) && $0.paymentTypeId ==  self.paymentOptionSelected?.getId()
        }
        guard let paymentMethods = filteredPaymentMethods else {
            return []
        }
        return paymentMethods
    }

    func payerInfoFlow() -> PayerInfoViewModel {
        let viewModel = PayerInfoViewModel(identificationTypes: self.identificationTypes!, payer: self.paymentData.payer!)
        return viewModel
    }
    
    func getPluginPaymentMethodToShow() -> [PXPaymentMethodPlugin] {
        _ = copyViewModelAndAssignToCheckoutStore()
        return paymentMethodPlugins.filter{$0.mustShowPaymentMethodPlugin(PXCheckoutStore.sharedInstance) == true}
    }

    // Returns lists of all payment option available
    fileprivate func getPaymentMethodsOptions(_ paymentMethodPluginsToShow: [PXPaymentMethodPlugin]) -> String {
        var paymentMethodsOptions = ""

        if let paymentMethods = search?.paymentMethods {
            for paymentMethod in paymentMethods {
                if let id = paymentMethod._id, let paymentTypeId = paymentMethod.paymentTypeId {
                    paymentMethodsOptions += "\(id):\(paymentTypeId)|"
                }
            }
        }

        if let customPaymentOptions = customPaymentOptions {
            for customCard in customPaymentOptions {
                paymentMethodsOptions += "\(customCard.getPaymentMethodId()):\(customCard.getPaymentTypeId()):\(customCard.getCardId())"
                if mpESCManager.getESC(cardId: customCard.getCardId()) != nil {
                    paymentMethodsOptions += ":ESC"
                }
                paymentMethodsOptions += "|"
            }
        }

        for paymentMethodPlugin in paymentMethodPluginsToShow {
            paymentMethodsOptions += "\(paymentMethodPlugin.getId()):\(PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue)|"
        }
        paymentMethodsOptions = String(paymentMethodsOptions.dropLast())
        return paymentMethodsOptions
    }

    func paymentVaultViewModel() -> PaymentVaultViewModel {
        var groupName: String?
        if let optionSelected = paymentOptionSelected {
            groupName = optionSelected.getId()
        }

        _ = copyViewModelAndAssignToCheckoutStore()
        let paymentMethodPluginsToShow = paymentMethodPlugins.filter{$0.mustShowPaymentMethodPlugin(PXCheckoutStore.sharedInstance) == true}

        // Get payment methods options for tracking in PaymentVault
        let paymentMethodsOptions = getPaymentMethodsOptions(paymentMethodPluginsToShow)
        PXTrackingStore.sharedInstance.addData(forKey: PXTrackingStore.PAYMENT_METHOD_OPTIONS, value: paymentMethodsOptions)

        return PaymentVaultViewModel(amount: self.getAmount(), paymentPrefence: getPaymentPreferences(), paymentMethodOptions: self.paymentMethodOptions!, customerPaymentOptions: self.customPaymentOptions, paymentMethodPlugins: paymentMethodPluginsToShow, groupName: groupName, isRoot: rootVC, discount: self.paymentData.discount, email: self.checkoutPreference.payer.email, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter, couponCallback: {[weak self] (discount) in
            guard let object = self else {
                return
            }
            object.paymentData.discount = discount
        })
    }

    public func entityTypeViewModel() -> AdditionalStepViewModel {
        return EntityTypeAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: self.paymentData.getPaymentMethod()!, dataSource: self.entityTypes!, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    public func financialInstitutionViewModel() -> AdditionalStepViewModel {
        return FinancialInstitutionAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: self.paymentData.getPaymentMethod()!, dataSource: self.financialInstitutions!, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    public func issuerViewModel() -> AdditionalStepViewModel {
        var paymentMethod: PaymentMethod = PaymentMethod()
        if let pm = self.paymentData.getPaymentMethod() {
            paymentMethod = pm
        }

        return IssuerAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: paymentMethod, dataSource: self.issuers!, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    public func payerCostViewModel() -> AdditionalStepViewModel {
        var paymentMethod: PaymentMethod = PaymentMethod()
        if let pm = self.paymentData.getPaymentMethod() {
            paymentMethod = pm
        }
        var cardInformation: CardInformationForm? = self.cardToken
        if cardInformation == nil {
            if let token = paymentOptionSelected as? CardInformationForm {
                cardInformation = token
            }
        }

        return PayerCostAdditionalStepViewModel(amount: self.getAmount(), token: cardInformation, paymentMethod: paymentMethod, dataSource: payerCosts!, discount: self.paymentData.discount, email: self.checkoutPreference.payer.email, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    public func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        let cardInformation = self.paymentOptionSelected as! CardInformation
        var reason: SecurityCodeViewModel.Reason
        if paymentResult != nil && paymentResult!.isInvalidESC() {
            reason = SecurityCodeViewModel.Reason.INVALID_ESC
        } else {
            reason = SecurityCodeViewModel.Reason.SAVED_CARD
        }
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: cardInformation, reason: reason)
    }

    public func cloneTokenSecurityCodeViewModel() -> SecurityCodeViewModel {
        let cardInformation = self.paymentData.token
        let reason = SecurityCodeViewModel.Reason.CALL_FOR_AUTH
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: cardInformation!, reason: reason)
    }

    func reviewConfirmViewModel() -> PXReviewViewModel {
        return PXReviewViewModel(checkoutPreference: self.checkoutPreference, paymentData : self.paymentData, paymentOptionSelected : self.paymentOptionSelected!, discount: paymentData.discount, reviewScreenPreference: reviewScreenPreference)
    }

    func resultViewModel() -> PXResultViewModel {
        return PXResultViewModel(paymentResult: self.paymentResult!, amount: self.getAmount(), instructionsInfo: self.instructionsInfo, paymentResultScreenPreference: self.paymentResultScreenPreference)
    }

    
    //SEARCH_PAYMENT_METHODS
    public func updateCheckoutModel(paymentMethods: [PaymentMethod], cardToken: CardToken?) {
        self.cleanPayerCostSearch()
        self.cleanIssuerSearch()
        self.cleanIdentificationTypesSearch()
        self.paymentData.updatePaymentDataWith(paymentMethod: paymentMethods[0])
        self.cardToken = cardToken
    }

    //CREDIT_DEBIT
    public func updateCheckoutModel(paymentMethod: PaymentMethod?) {
        if let paymentMethod = paymentMethod {
            self.paymentData.updatePaymentDataWith(paymentMethod: paymentMethod)
        }
    }

    public func updateCheckoutModel(financialInstitution: FinancialInstitution) {
        if let TDs = self.paymentData.transactionDetails {
            TDs.financialInstitution = financialInstitution
        } else {
            let TD = TransactionDetails(financialInstitution: financialInstitution)
            self.paymentData.transactionDetails = TD
        }
    }

    public func updateCheckoutModel(issuer: Issuer) {
        self.cleanPayerCostSearch()
        self.paymentData.updatePaymentDataWith(issuer: issuer)
    }

    public func updateCheckoutModel(payer: Payer) {
        self.paymentData.updatePaymentDataWith(payer: payer)
    }

    public func updateCheckoutModel(identificationTypes: [IdentificationType]) {
        self.identificationTypes = identificationTypes
    }

    public func updateCheckoutModel(identification: Identification) {
        self.paymentData.cleanToken()
        self.paymentData.cleanIssuer()
        self.paymentData.cleanPayerCost()
        self.cleanPayerCostSearch()
        self.cleanIssuerSearch()

        if paymentData.hasPaymentMethod() && paymentData.getPaymentMethod()!.isCard {
            self.cardToken!.cardholder!.identification = identification
        } else {
            paymentData.payer?.identification = identification
        }
    }

    public func updateCheckoutModel(payerCost: PayerCost) {
        self.paymentData.updatePaymentDataWith(payerCost: payerCost)

        if let paymentOptionSelected = paymentOptionSelected {
            if paymentOptionSelected.isCustomerPaymentMethod() {
                self.paymentData.cleanToken()
            }
        }
    }

    public func updateCheckoutModel(entityType: EntityType) {
        self.paymentData.payer?.entityType = entityType
    }

    // MARK: PAYMENT METHOD OPTION SELECTION
    public func updateCheckoutModel(paymentOptionSelected: PaymentMethodOption) {
        if !self.initWithPaymentData {
            resetInFormationOnNewPaymentMethodOptionSelected()
        }
        resetPaymentOptionSelectedWith(newPaymentOptionSelected: paymentOptionSelected)
    }

    public func resetPaymentOptionSelectedWith(newPaymentOptionSelected: PaymentMethodOption) {
        self.paymentOptionSelected = newPaymentOptionSelected

        if let targetPlugin = paymentOptionSelected as? PXPaymentMethodPlugin {
            self.paymentMethodPluginToPaymentMethod(plugin: targetPlugin)
            return
        }

        if newPaymentOptionSelected.hasChildren() {
            self.paymentMethodOptions =  newPaymentOptionSelected.getChildren()
        }

        if self.paymentOptionSelected!.isCustomerPaymentMethod() {
            self.findAndCompletePaymentMethodFor(paymentMethodId: newPaymentOptionSelected.getId())
        } else if !newPaymentOptionSelected.isCard() && !newPaymentOptionSelected.hasChildren() {
            self.paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: newPaymentOptionSelected.getId()))
        }
    }

    public func nextStep() -> CheckoutStep {

        if !startedCheckout {
            startedCheckout = true
            return .START
        }
        if hasError() {
            return .SCREEN_ERROR
        }

        if needLoadPreference {
            needLoadPreference = false
            return .SERVICE_GET_PREFERENCE
        }
        if needToSearchDirectDiscount() {
            self.directDiscountSearched = true
            return .SERVICE_GET_DIRECT_DISCOUNT
        }

        if shouldExitCheckout() {
            return .ACTION_FINISH
        }

        if needToGetInstructions() {
            return .SERVICE_GET_INSTRUCTIONS
        }

        if shouldShowCongrats() {
            return .SCREEN_PAYMENT_RESULT
        }

        if needValidatePreference() {
            preferenceValidated = true
            return .ACTION_VALIDATE_PREFERENCE
        }

        if needToInitPaymentMethodPlugins() {
            return .SERVICE_PAYMENT_METHOD_PLUGIN_INIT
        }

        if needSearch() {
            return .SERVICE_GET_PAYMENT_METHODS
        }

        if !isPaymentTypeSelected() {
            return .SCREEN_PAYMENT_METHOD_SELECTION
        }

        if shouldShowHook(hookStep: .BEFORE_PAYMENT_METHOD_CONFIG) {
            return .SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG
        }

        if needToShowPaymentMethodConfigPlugin() {
            willShowPaymentMethodConfigPlugin()
            return .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
        }

        if shouldShowHook(hookStep: .AFTER_PAYMENT_METHOD_CONFIG) {
            return .SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG
        }

        if shouldShowHook(hookStep: .BEFORE_PAYMENT) {
            return .SCREEN_HOOK_BEFORE_PAYMENT
        }

        if needToCreatePaymentForPaymentPlugin() {
            readyToPay = false
            return .SCREEN_PAYMENT_PLUGIN_PAYMENT
        }

        if needToCreatePaymentForPaymentMethodPlugin() {
            readyToPay = false
            return .SCREEN_PAYMENT_METHOD_PLUGIN_PAYMENT
        }

        if needToCreatePayment() {
            readyToPay = false
            return .SERVICE_POST_PAYMENT
        }

        if needReviewAndConfirm() {
            return .SCREEN_REVIEW_AND_CONFIRM
        }

        if needCompleteCard() {
            return .SCREEN_CARD_FORM
        }

        if needToGetIdentificationTypes() {
            return .SERVICE_GET_IDENTIFICATION_TYPES
        }

        if needToGetPayerInfo() {
            return .SCREEN_PAYER_INFO_FLOW
        }

        if needGetIdentification() {
            return .SCREEN_IDENTIFICATION
        }

        if needSecurityCode() {
            return .SCREEN_SECURITY_CODE
        }

        if needCreateToken() {
            return .SERVICE_CREATE_CARD_TOKEN
        }

        if needGetEntityTypes() {
            return .SCREEN_ENTITY_TYPE
        }

        if needGetFinancialInstitutions() {
            return .SCREEN_FINANCIAL_INSTITUTIONS
        }

        if needGetIssuers() {
            return .SERVICE_GET_ISSUERS
        }

        if needIssuerSelectionScreen() {
            return .SCREEN_ISSUERS
        }

        if needChosePayerCost() {
            return .SERVICE_GET_PAYER_COSTS
        }

        if needPayerCostSelectionScreen() {
            return .SCREEN_PAYER_COST
        }

        return .ACTION_FINISH
    }

    var search: PaymentMethodSearch?

    fileprivate func autoselectOnlyPaymentMethod() {
        guard let search = self.search else {
            return
        }
        
        self.reviewScreenPreference.disableChangeMethodOption()
        
        if !Array.isNullOrEmpty(search.groups) && search.groups.count == 1 {
            self.updateCheckoutModel(paymentOptionSelected: search.groups[0])
        } else if !Array.isNullOrEmpty(search.customerPaymentMethods) && search.customerPaymentMethods?.count == 1{
            let customOption = search.customerPaymentMethods![0] as! PaymentMethodOption
            self.updateCheckoutModel(paymentOptionSelected: customOption)
        } else if  !Array.isNullOrEmpty(paymentMethodPluginsToShow) && paymentMethodPluginsToShow.count == 1 {
            self.updateCheckoutModel(paymentOptionSelected: paymentMethodPluginsToShow[0])
        }
    }
    
    public func updateCheckoutModel(paymentMethodSearch: PaymentMethodSearch) {
        
        self.search = paymentMethodSearch
        
        guard let search = self.search else {
            return
        }
        
        self.rootPaymentMethodOptions = paymentMethodSearch.groups
        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.availablePaymentMethods = paymentMethodSearch.paymentMethods
        
        if !Array.isNullOrEmpty(paymentMethodSearch.customerPaymentMethods) {
            if !MercadoPagoContext.accountMoneyAvailable() {
                //Remover account_money como opción de pago
                self.customPaymentOptions =  paymentMethodSearch.customerPaymentMethods!.filter({ (element: CardInformation) -> Bool in
                    return element.getPaymentMethodId() != PaymentTypeId.ACCOUNT_MONEY.rawValue
                })
            } else {
                self.customPaymentOptions = paymentMethodSearch.customerPaymentMethods
            }
        }
        
        let totalPaymentMethodSearchCount = search.getPaymentOptionsCount()
        self.paymentMethodPluginsToShow = getPluginPaymentMethodToShow()
        let totalPaymentMethodsToShow =  totalPaymentMethodSearchCount + paymentMethodPluginsToShow.count
        
        if totalPaymentMethodsToShow == 0 {
            self.errorInputs(error: MPSDKError(message: PXStrings.error_title.PXLocalized, errorDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized_temp, retry: false), errorCallback: { (_) in
            })
        } else if totalPaymentMethodsToShow == 1 {
            autoselectOnlyPaymentMethod()
        }
    }

    public func updateCheckoutModel(token: Token) {
        self.paymentData.updatePaymentDataWith(token: token)
    }

    public class func createMPPayment(preferenceId: String, paymentData: PaymentData, customerId: String? = nil, binaryMode: Bool) -> MPPayment {

        let issuerId: String = paymentData.hasIssuer() ? paymentData.getIssuer()!._id! : ""

        let tokenId: String = paymentData.hasToken() ? paymentData.getToken()!._id : ""

        let installments = paymentData.hasPayerCost() ? paymentData.getPayerCost()!.installments : 0

        var transactionDetails = TransactionDetails()
        if paymentData.transactionDetails != nil {
            transactionDetails = paymentData.transactionDetails!
        }

        var payer = Payer()
        if let targetPayer = paymentData.payer {
            payer = targetPayer
        }

        let isBlacklabelPayment = paymentData.hasToken() && paymentData.getToken()!.cardId != nil && String.isNullOrEmpty(customerId)

        let mpPayment = MPPaymentFactory.createMPPayment(preferenceId: preferenceId, publicKey: MercadoPagoContext.publicKey(), paymentMethodId: paymentData.getPaymentMethod()!._id, installments: installments, issuerId: issuerId, tokenId: tokenId, customerId: customerId, isBlacklabelPayment: isBlacklabelPayment, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode)
        return mpPayment
    }

    public func updateCheckoutModel(paymentMethodOptions: [PaymentMethodOption]) {
        if self.rootPaymentMethodOptions != nil {
            self.rootPaymentMethodOptions!.insert(contentsOf: paymentMethodOptions, at: 0)
        } else {
            self.rootPaymentMethodOptions = paymentMethodOptions
        }
        self.paymentMethodOptions = self.rootPaymentMethodOptions
    }

    func updateCheckoutModel(paymentData: PaymentData) {
        self.paymentData = paymentData
        if paymentData.getPaymentMethod() == nil {
            // Vuelvo a root para iniciar la selección de medios de pago
            self.paymentOptionSelected = nil
            self.paymentMethodOptions = self.rootPaymentMethodOptions
            self.search = nil
            self.rootVC = true
            self.cardToken = nil
            self.issuers = nil
            self.entityTypes = nil
            self.financialInstitutions = nil
            self.payerCosts = nil
            self.initWithPaymentData = false
        } else {
            self.readyToPay = true
        }

    }

    public func updateCheckoutModel(payment: Payment) {
        self.payment = payment
        self.paymentResult = PaymentResult(payment: self.payment!, paymentData: self.paymentData)
    }

    internal func getAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        } else if isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        } else {
            return self.checkoutPreference.getAmount()
        }
    }

    public func isCheckoutComplete() -> Bool {
        return checkoutComplete
    }

    public func setIsCheckoutComplete(isCheckoutComplete: Bool) {
        self.checkoutComplete = isCheckoutComplete
    }

    internal func findAndCompletePaymentMethodFor(paymentMethodId: String) {
        if paymentMethodId == PaymentTypeId.ACCOUNT_MONEY.rawValue {
            self.paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentMethodId))
        } else {
            let cardInformation = (self.paymentOptionSelected as! CardInformation)
            let paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId:cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            self.paymentData.updatePaymentDataWith(paymentMethod: cardInformation.getPaymentMethod())
            self.paymentData.updatePaymentDataWith(issuer: cardInformation.getIssuer())
        }

    }

    func hasCustomPaymentOptions() -> Bool {
        return !Array.isNullOrEmpty(self.customPaymentOptions)
    }

    internal func handleCustomerPaymentMethod() {
        if self.paymentOptionSelected!.getId() == PaymentTypeId.ACCOUNT_MONEY.rawValue {
            self.paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentOptionSelected!.getId()))
        } else {
            // Se necesita completar información faltante de settings y pm para custom payment options
            let cardInformation = (self.paymentOptionSelected as! CardInformation)
            let paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            self.paymentData.updatePaymentDataWith(paymentMethod: cardInformation.getPaymentMethod())
        }
    }
    func getDefaultPaymentMethodId() -> String? {
        return self.checkoutPreference.getDefaultPaymentMethodId()
    }

    func getExcludedPaymentTypesIds() -> Set<String>? {
        if self.checkoutPreference.siteId == "MLC" || self.checkoutPreference.siteId == "MCO" || self.checkoutPreference.siteId == "MLV" {
            self.checkoutPreference.addExcludedPaymentType("atm")
            self.checkoutPreference.addExcludedPaymentType("bank_transfer")
            self.checkoutPreference.addExcludedPaymentType("ticket")
        }
        return self.checkoutPreference.getExcludedPaymentTypesIds()
    }

    func getExcludedPaymentMethodsIds() -> Set<String>? {
        return self.checkoutPreference.getExcludedPaymentMethodsIds()
    }

    func entityTypesFinder(inDict: NSDictionary, forKey: String) -> [EntityType]? {

        if let siteETsDictionary = inDict.value(forKey: forKey) as? NSDictionary {
            let entityTypesKeys = siteETsDictionary.allKeys
            var entityTypes = [EntityType]()

            for ET in entityTypesKeys {
                let entityType = EntityType()
                entityType._id = ET as! String
                entityType.name = (siteETsDictionary.value(forKey: ET as! String) as! String!).localized_temp

                entityTypes.append(entityType)
            }

            return entityTypes
        }

        return nil
    }

    func getEntityTypes() -> [EntityType] {
        let path = MercadoPago.getBundle()!.path(forResource: "EntityTypes", ofType: "plist")
        let dictET = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()

        if let siteETs = entityTypesFinder(inDict: dictET!, forKey: site) {
            return siteETs
        } else {
            let siteETs = entityTypesFinder(inDict: dictET!, forKey: "default")
            return siteETs!
        }
    }

    func errorInputs(error: MPSDKError, errorCallback: (() -> Void)?) {
        MercadoPagoCheckoutViewModel.error = error
        self.errorCallback = errorCallback
    }

    func shouldDisplayPaymentResult() -> Bool {
        guard let paymentResult = self.paymentResult else {
            return false
        }
        if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentResultScreenEnable() {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentApprovedScreenEnable() && paymentResult.isApproved() {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentPendingScreenEnable() && paymentResult.isInProcess() {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentRejectedScreenEnable() && paymentResult.isRejected() {
            return false
        }
        return true
    }

    func saveOrDeleteESC() -> Bool {
        guard let paymetResult = self.paymentResult, let token = paymentResult?.paymentData?.getToken() else {
            return false
        }
        if token.hasCardId() {
            if paymetResult.isApproved() && token.hasESC() {
                return mpESCManager.saveESC(cardId: token.cardId, esc: token.esc!)
            } else {
                mpESCManager.deleteESC(cardId: token.cardId)
                return false
            }
        }
        return false
    }

    func copyViewModelAndAssignToCheckoutStore() -> Bool {
        // Set a copy of CheckoutVM in HookStore
        if self.copy() is MercadoPagoCheckoutViewModel {
            PXCheckoutStore.sharedInstance.paymentData = self.paymentData
            PXCheckoutStore.sharedInstance.paymentOptionSelected = self.paymentOptionSelected
            PXCheckoutStore.sharedInstance.checkoutPreference = self.checkoutPreference
            return true
        }
        return false
    }
}

extension MercadoPagoCheckoutViewModel {
    func resetGroupSelection() {
        self.paymentOptionSelected = nil
        guard let search = self.search else {
            return
        }
        self.updateCheckoutModel(paymentMethodSearch: search)
    }

    func resetInFormationOnNewPaymentMethodOptionSelected() {
        resetInformation()
        MercadoPagoCheckoutViewModel.flowPreference.resetHooksToShow()
    }

    func resetInformation() {
        self.paymentData.clearCollectedData()
        self.cardToken = nil
        self.entityTypes = nil
        self.financialInstitutions = nil
        cleanPayerCostSearch()
        cleanIssuerSearch()
        cleanIdentificationTypesSearch()
        resetPaymentMethodConfigPlugin()
    }

    func cleanPayerCostSearch() {
        self.payerCosts = nil
    }

    func cleanIssuerSearch() {
        self.issuers = nil
    }

    func cleanIdentificationTypesSearch() {
        self.identificationTypes = nil
    }

    func cleanPaymentResult() {
        self.payment = nil
        self.paymentResult = nil
        self.readyToPay = false
        self.setIsCheckoutComplete(isCheckoutComplete: false)
    }

    func prepareForClone() {
        self.setIsCheckoutComplete(isCheckoutComplete: false)
        self.cleanPaymentResult()
        self.wentBackFrom(hook: .BEFORE_PAYMENT)
    }

    func prepareForNewSelection() {
        self.setIsCheckoutComplete(isCheckoutComplete: false)
        self.cleanPaymentResult()
        self.resetInformation()
        self.resetGroupSelection()
        self.rootVC = true
        MercadoPagoCheckoutViewModel.flowPreference.resetHooksToShow()
    }

    func prepareForInvalidPaymentWithESC() {
        if self.paymentData.isComplete() {
            readyToPay = true
            self.savedESCCardToken = SavedESCCardToken(cardId: self.paymentData.getToken()!.cardId, esc: nil)
            mpESCManager.deleteESC(cardId: self.paymentData.getToken()!.cardId)
        }

        self.paymentData.cleanToken()
    }

    static internal func clearEnviroment() {
        MercadoPagoCheckoutViewModel.servicePreference = ServicePreference()
        MercadoPagoCheckoutViewModel.flowPreference = FlowPreference()
        MercadoPagoCheckoutViewModel.paymentDataCallback = nil
        MercadoPagoCheckoutViewModel.paymentDataConfirmCallback = nil
        MercadoPagoCheckoutViewModel.paymentCallback = nil
        MercadoPagoCheckoutViewModel.changePaymentMethodCallback = nil
        MercadoPagoCheckoutViewModel.error = nil
    }
}
