//
//  PXOnetapSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

@available(iOS 10.0, *)
final class PXOneTapSheetViewController: PXSheetViewController {
    // MARK: Definitions
    lazy var itemViews = [UIView]()
    private var viewModel: PXOneTapViewModel?
    private lazy var footerView: UIView = UIView()

    // MARK: Callbacks
    private var callbackPaymentData: ((PaymentData) -> Void)?
    private var callbackConfirm: ((PaymentData) -> Void)?
    private var callbackExit: (() -> Void)?
    private var callbackShowCongrats: (() -> Void)?

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
@available(iOS 10.0, *)
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

    func setShowCongratsCallback(callback: @escaping (() -> Void)) {
        callbackShowCongrats = callback
    }
}

// MARK: Components Builders.
@available(iOS 10.0, *)
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
        var loadingButtonComponent: PXAnimatedButton?
        let mainAction = PXComponentAction(label: "Pagar", action: { [weak self] in
            //self?.confirmPayment()
            loadingButtonComponent?.startLoading(loadingText:"Pagando...", retryText:"Pagar")
        })
        let footerProps = PXFooterProps(buttonAction: mainAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        if let footerView = footerComponent.oneTapRender() as? PXFooterView {
            loadingButtonComponent = footerView.getPrincipalButton()
            loadingButtonComponent?.animationDelegate = self
            loadingButtonComponent?.layer.cornerRadius = 4
            return footerView
        }
        return nil
    }

    private func getDiscountDetailView() -> UIView? {
        //TODO: (Nutria team) - Make Discount detail view.
        let discountDetailView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 900))
        discountDetailView.backgroundColor = .red
        return discountDetailView
    }
}

// MARK: User Actions.
@available(iOS 10.0, *)
extension PXOneTapSheetViewController {
    @objc func shouldOpenSummary() {
        // expandSheet()
        if let vm = viewModel, vm.shouldShowSummaryModal() {
            if let summaryProps = vm.getSummaryProps(), summaryProps.count > 0 {
                let summaryViewController = PXOneTapSummaryModalViewController()
                summaryViewController.setProps(summaryProps: summaryProps, bottomCustomView: getDiscountDetailView())
                //TODO: "Detalle" translation. Pedir a contenidos.
                PXComponentFactory.Modal.show(viewController: summaryViewController, title: "Detalle".localized)
            } else {
                if let discountView = getDiscountDetailView() {
                    let summaryViewController = PXOneTapSummaryModalViewController()
                    summaryViewController.setProps(summaryProps: nil, bottomCustomView: discountView)
                    PXComponentFactory.Modal.show(viewController: summaryViewController, title: nil)
                }
            }
        }
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

//MARK: - Payment Button animation delegate
@available(iOS 10.0, *)
extension PXOneTapSheetViewController: PXAnimatedButtonDelegate {
    func expandAnimationInProgress() {
        expandSheet(fullScreen: true)
    }

    func didFinishAnimation() {
        callbackShowCongrats?()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.alpha = 0
        }) { finish in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: Animated Transitions.
@available(iOS 10.0, *)
extension PXOneTapSheetViewController {
    private func openGroupsTransitionAnimation() {
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
    }
}
