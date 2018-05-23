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
        let reviewVC: PXOneTapSheetViewController = PXOneTapSheetViewController()
        reviewVC.update(viewModel: viewModel.reviewConfirmViewModel())

        guard let viewController = self.pxNavigationHandler.navigationController.viewControllers.last else {
            fatalError("Checkout express doesn't work in a empty navigation controller")
        }
        reviewVC.modalPresentationStyle = .overCurrentContext
        viewController.present(reviewVC, animated: false, completion: {
            print("ExpressViewController Done")
        })
        //self.pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as? CardInformation, securityCode: securityCode)
        })
        self.pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}
