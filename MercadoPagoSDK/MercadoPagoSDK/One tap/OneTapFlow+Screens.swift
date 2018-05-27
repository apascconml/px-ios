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
        sheetVC.setChangePaymentMethodCallback { [weak self] (paymentData: PaymentData) in

            // TODO: Ver con edi.
            /*
            if let search = self?.viewModel.search {
                search.deleteCheckoutDefaultOption()
            }*/

            self?.viewModel.search.deleteCheckoutDefaultOption()
            self?.cancelFlow()
            self?.executeNextStep()

            /*
            if !paymentData.hasPaymentMethod() && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
                MercadoPagoCheckoutViewModel.changePaymentMethodCallback?()
            }
            return*/
        }

        // Congrats action callback.
        sheetVC.setShowCongratsCallback {
            [weak self] in

            /*

             // TODO: Ver con edi.
            self?.viewModel.businessResult = PXBusinessResult(status: PXBusinessResultStatus.APPROVED, title: "Pago confirmado", icon: MercadoPago.getImage("MPSDK_review_iconoCarrito")!, secondaryAction: PXComponentAction(label: "Continuar", action: {
                self?.cancel()
            })) */
            self?.executeNextStep()
        }

        // Exit callback.
        sheetVC.setExitCallback { [weak self] () -> Void in
            self?.cancelFlow()
        }

        sheetVC.modalPresentationStyle = .overCurrentContext
        viewController.present(sheetVC, animated: false, completion: {
            print("PXOneTapSheetViewController Done")
        })
    }
}
