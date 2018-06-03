//
//  OneTapFlow+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow {
    func showReviewAndConfirmScreenForOneTap() {
        showOneTapSheetVC()
        //showOneTapVC()
        // TODO: AB Testing or iPhoneX-8 if.
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as? CardInformation, securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}

// MARK: Sheet
extension OneTapFlow {

    private func showOneTapVC() {
        let reviewVC = PXOneTapViewController(viewModel: viewModel.reviewConfirmViewModel(), callbackPaymentData: { [weak self] (paymentData: PaymentData) in

            if let search = self?.viewModel.search {
                search.deleteCheckoutDefaultOption()
            }
            self?.cancelFlow()

            if !paymentData.hasPaymentMethod() && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
                MercadoPagoCheckoutViewModel.changePaymentMethodCallback?()
            }
            return

            }, callbackConfirm: {(paymentData: PaymentData) in
                self.viewModel.updateCheckoutModel(paymentData: paymentData)

                // Deletes default one tap option in payment method search
                self.viewModel.search.deleteCheckoutDefaultOption()

                if MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil {
                    MercadoPagoCheckoutViewModel.paymentDataCallback = MercadoPagoCheckoutViewModel.paymentDataConfirmCallback
                    self.finishFlow()
                } else {
                    self.executeNextStep()
                }

        }, callbackExit: { [weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.cancelFlow()
        })
        pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    private func showOneTapSheetVC() {

        if #available(iOS 10.0, *) {

            let sheetVC: PXOneTapSheetViewController = PXOneTapSheetViewController()

            guard let viewController = self.pxNavigationHandler.navigationController.viewControllers.last else {
                fatalError("Sheet checkout express doesn't work in a empty parent navigation controller")
            }

            sheetVC.update(viewModel: viewModel.reviewConfirmViewModel())

            // Payment action callback.
            sheetVC.setConfirmCallback { [weak self] (paymentData: PaymentData) in
                self?.viewModel.updateCheckoutModel(paymentData: paymentData)
                if MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil {
                    MercadoPagoCheckoutViewModel.paymentDataCallback = MercadoPagoCheckoutViewModel.paymentDataConfirmCallback
                    self?.finishFlow()
                } else {
                    self?.executeNextStep()
                }
            }

            // Change payment method callback.
            sheetVC.setChangePaymentMethodCallback { (paymentData: PaymentData) in
                self.viewModel.search.deleteCheckoutDefaultOption()
                self.cancelFlow()

                if !paymentData.hasPaymentMethod() && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
                    MercadoPagoCheckoutViewModel.changePaymentMethodCallback?()
                }
                return
            }

            // Congrats action callback.
            sheetVC.setShowCongratsCallback {
                [weak self] in

                /*
                 // TODO: Ver con edi.
                 self?.viewModel.businessResult = PXBusinessResult(status: PXBusinessResultStatus.APPROVED, title: "Pago confirmado", icon: MercadoPago.getImage("MPSDK_review_iconoCarrito")!, secondaryAction: PXComponentAction(label: "Continuar", action: {
                 self?.cancel()
                 })) */
                //self?.executeNextStep()

                // ONLY FOR DEMO: SHOW STATIC CONGRATS.
                var congratsVC: PXResultViewController?

                let businessResult = PXBusinessResult(status: PXBusinessResultStatus.APPROVED, title: "Pago confirmado", icon: MercadoPago.getImage("MPSDK_review_iconoCarrito")!, secondaryAction:
                    PXCloseLinkAction()
                )

                let businesResultViewModel = PXBusinessResultViewModel(businessResult: businessResult, paymentData: (self?.viewModel.paymentData)!, amount: (self?.viewModel.getAmount())!)

                congratsVC = PXResultViewController(viewModel: businesResultViewModel, callback: { _ in})

                if let vcCongrats = congratsVC {
                    self?.pxNavigationHandler.pushViewController(viewController: vcCongrats, animated: false)
                }
                // END - ONLY FOR DEMO: SHOW STATIC CONGRATS.
            }

            // Exit callback.
            sheetVC.setExitCallback { [weak self] () -> Void in
                self?.cancelFlow()
            }

            sheetVC.modalPresentationStyle = .overCurrentContext
            viewController.present(sheetVC, animated: false, completion: {
                print("PXOneTapSheetViewController Done")
            })
        } else {
            showOneTapVC()
        }
    }
}
