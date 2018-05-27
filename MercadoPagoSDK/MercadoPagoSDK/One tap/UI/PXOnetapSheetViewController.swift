//
//  PXOnetapSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

final class PXOneTapSheetViewController: PXSheetViewController {
    // MARK: Definitions
    lazy var itemViews = [UIView]()
    private var viewModel: PXOneTapViewModel?
    private lazy var footerView: UIView = UIView()

    // MARK: Callbacks
    private var callbackPaymentData: ((PaymentData) -> Void)?
    private var callbackConfirm: ((PaymentData) -> Void)?
    private var callbackExit: (() -> Void)?

    // MARK: PXSheeDelegate overrides
    override func contentViewForSheet() -> UIView {
        return renderContentView()
    }

    override func titleForSheet() -> String? {
        return "Confirma tu compra"
    }

    override func contentTopMargin() -> CGFloat {
        return PXLayout.M_MARGIN
    }

    override func contentBottomMargin() -> CGFloat {
        let bottomSafeAreaInset = PXLayout.getSafeAreaBottomInset()
        if bottomSafeAreaInset > 0 {
            return bottomSafeAreaInset
        }
        return PXLayout.M_MARGIN
    }
}

// MARK: Public Setters
extension PXOneTapSheetViewController {
    func update(viewModel: PXOneTapViewModel) {
        self.viewModel = viewModel
    }

    func setChangePaymentMethodCallback(callback: @escaping ((PaymentData) -> Void)) {
        callbackPaymentData = callback
    }

    func setConfirmCallback(callback: @escaping ((PaymentData) -> Void)) {
        callbackConfirm = callback
    }

    func setExitCallback(callback: @escaping (() -> Void)) {
        callbackExit = callback
    }
}

// MARK: Components Builders.
extension PXOneTapSheetViewController {
    private func renderContentView() -> UIView {

        let view: UIView = UIView()
        if let itemView = getItemComponentView() {
            // Add item-price view.
            view.addSubview(itemView)
            PXLayout.matchWidth(ofView: itemView).isActive = true
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.pinTop(view: itemView).isActive = true
            let itemTapGestureAction = UITapGestureRecognizer(target: self, action: #selector(self.shouldOpenSummary))
            itemView.addGestureRecognizer(itemTapGestureAction)

            // Add payment method.
            if let paymentMethodView = getPaymentMethodComponentView() {
                view.addSubview(paymentMethodView)
                PXLayout.centerHorizontally(view: paymentMethodView).isActive = true
                PXLayout.put(view: paymentMethodView, onBottomOf: itemView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinLeft(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinRight(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
                let paymentMethodTapAction = UITapGestureRecognizer(target: self, action: #selector(self.shouldChangePaymentMethod))
                paymentMethodView.addGestureRecognizer(paymentMethodTapAction)
            }

            // Add Footer
            if let footerView = getFooterView() {
                view.addSubview(footerView)
                PXLayout.matchWidth(ofView: footerView).isActive = true
                PXLayout.pinBottom(view: footerView).isActive = true
                PXLayout.centerHorizontally(view: footerView).isActive = true
            }
        }
        return view
    }

    private func getItemComponentView() -> UIView? {
        if let oneTapItemComponent = viewModel?.getItemComponent() {
            return oneTapItemComponent.render()
        }
        return nil
    }

    private func getPaymentMethodComponentView() -> UIView? {
        if let paymentMethodComponent = viewModel?.getPaymentMethodComponent() {
            return paymentMethodComponent.oneTapRender()
        }
        return nil
    }

    private func getFooterView() -> UIView? {
        //var loadingButtonComponent: PXPrimaryButton?
        let mainAction = PXComponentAction(label: "Pagar", action: { [weak self] in
            // self?.confirmPayment()
            // loadingButtonComponent?.startLoading(loadingText:"Pagando...", retryText:"Pagar")
        })
        let footerProps = PXFooterProps(buttonAction: mainAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        if let footerView = footerComponent.oneTapRender() as? PXFooterView {
            //loadingButtonComponent = footerV.getPrincipalButton()
            //loadingButtonComponent?.animationDelegate = self
            return footerView
        }
        return nil
    }
}

// MARK: User Actions.
extension PXOneTapSheetViewController {
    @objc func shouldOpenSummary() {
        expandSheet()
        /* TODO: Show Summary
        if let summaryProps = viewModel?.getSummaryProps(), summaryProps.count > 0 {
            let summaryViewController = PXOneTapSummaryModalViewController()
            summaryViewController.setProps(summaryProps: viewModel?.getSummaryProps())
            PXComponentFactory.Modal.show(viewController: summaryViewController, title: nil)
        } */
    }

    @objc func shouldChangePaymentMethod() {
        openGroupsTransitionAnimation()
    }

    private func changePaymentMethodAction() {
        viewModel?.trackChangePaymentMethodEvent()
        if let callbackAction = callbackPaymentData, let vm = viewModel {
            callbackAction(vm.getClearPaymentData())
        }
    }

    private func confirmPayment() {
        viewModel?.trackConfirmActionEvent()
        if let callbackAction = self.callbackConfirm, let vm = viewModel {
            callbackAction(vm.paymentData)
        }
    }

    private func cancelPayment() {
        callbackExit?()
    }
}

// MARK: Animated Transitions.
extension PXOneTapSheetViewController {
    private func openGroupsTransitionAnimation() {
        if #available(iOS 10.0, *) {
            let targetFrame = view.frame
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1.3, animations: { [weak self] in
                self?.popupView.frame = targetFrame
                self?.popupView.layer.cornerRadius = 0
            })

            transitionAnimator.addCompletion({ [weak self] _ in
                self?.changePaymentMethodAction()
                self?.fadeOut()
            })

            transitionAnimator.startAnimation()

            let overlayWhite = UIView(frame: self.view.frame)
            overlayWhite.alpha = 0
            overlayWhite.backgroundColor = .white
            popupView.addSubview(overlayWhite)
            UIView.animate(withDuration: 0.5, animations: {
                overlayWhite.alpha = 1
            })
        } else {
            changePaymentMethodAction()
        }
    }
}
