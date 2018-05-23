//
//  PXOnetapSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

final class PXOneTapSheetViewController: UIViewController {

    //Sheet
    let popUpViewHeight: CGFloat = 465
    let borderMargin = PXLayout.XXXS_MARGIN
    var blurView: UIVisualEffectView = UIVisualEffectView()
    fileprivate var bottomConstraint = NSLayoutConstraint()

    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel?
    private lazy var footerView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheet()
    }

    func update(viewModel: PXOneTapViewModel) {
        self.viewModel = viewModel
    }

    fileprivate lazy var popupView: UIView = {

        let view = UIView()
        let boldColor: UIColor = ThemeManager.shared.boldLabelTintColor()
        let modalTitle: String = "Confirma tu compra"
        let closeButtonImage = MercadoPago.getImage("white_close")?.withRenderingMode(.alwaysTemplate)
        let closeButtonColor: UIColor = ThemeManager.shared.labelTintColor()

        let RADIUS_WITH_SAFE_AREA: CGFloat = 32
        let RADIUS_WITHOUT_SAFE_AREA: CGFloat = 15
        let TITLE_VIEW_HEIGHT: CGFloat = 58

        view.alpha = 1

        if PXLayout.getSafeAreaTopInset() > 0 {
            view.layer.cornerRadius = RADIUS_WITH_SAFE_AREA
        } else {
            view.layer.cornerRadius = RADIUS_WITHOUT_SAFE_AREA
        }

        view.clipsToBounds = true

        //Title
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        PXLayout.matchWidth(ofView: titleView).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.pinTop(view: titleView).isActive = true
        PXLayout.setHeight(owner: titleView, height: TITLE_VIEW_HEIGHT).isActive = true


        let line = UIView()
        //line.alpha = 0.6
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .UIColorFromRGB(0xEEEEEE)
        titleView.addSubview(line)
        PXLayout.pinBottom(view: line).isActive = true
        PXLayout.matchWidth(ofView: line).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: 1).isActive = true


        let titleLabel = UILabel()
        titleView.addSubview(titleLabel)
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.M_MARGIN - 4
            ).isActive = true
        PXLayout.matchWidth(ofView: titleLabel).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true
        PXLayout.setHeight(owner: titleLabel, height: TITLE_VIEW_HEIGHT).isActive = true
        titleLabel.text = modalTitle.localized
        titleLabel.font = Utils.getFont(size: PXLayout.M_FONT)
        titleLabel.textColor = boldColor

        //Cancel button
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.add(for: .touchUpInside, {
            self.hideSheet()
        })
        button.setImage(closeButtonImage, for: .normal)
        button.tintColor = closeButtonColor
        titleView.addSubview(button)
        PXLayout.pinRight(view: button, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setWidth(owner: button, width: 50).isActive = true
        PXLayout.setHeight(owner: button, height: 30).isActive = true


        // Create item-price view.
        if let itemView = getItemComponentView() {

            // Add item-price view.
            view.addSubview(itemView)
            PXLayout.matchWidth(ofView: itemView).isActive = true
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.put(view: itemView, onBottomOf: titleView, withMargin: PXLayout.M_MARGIN).isActive = true

            // Add payment method.
            if let paymentMethodView = getPaymentMethodComponentView() {
                view.addSubview(paymentMethodView)
                PXLayout.centerHorizontally(view: paymentMethodView).isActive = true
                PXLayout.put(view: paymentMethodView, onBottomOf: itemView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinLeft(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinRight(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
                //let paymentMethodTapAction = UITapGestureRecognizer(target: self, action: #selector(self.shouldChangePaymentMethod))
                //paymentMethodView.addGestureRecognizer(paymentMethodTapAction)
            }

            //Footer
            var footerView: PXFooterView = PXFooterView()
            var loadingButtonComponent: PXPrimaryButton?
            let mainAction = PXComponentAction(label: "Pagar", action: {
                print("Debug - Pagando")
                //loadingButtonComponent?.startLoading(loadingText:"Pagando...", retryText:"Pagar")
            })
            let footerProps = PXFooterProps(buttonAction: mainAction)
            let footerComponent = PXFooterComponent(props: footerProps)
            footerView = footerComponent.oneTapRender() as! PXFooterView
            loadingButtonComponent = footerView.getPrincipalButton()
            //loadingButtonComponent?.animationDelegate = self
            view.addSubview(footerView)
            PXLayout.matchWidth(ofView: footerView).isActive = true
            PXLayout.pinBottom(view: footerView).isActive = true
            PXLayout.centerHorizontally(view: footerView).isActive = true

            view.layoutIfNeeded()
            view.backgroundColor = UIColor.white

        }

        return view
    }()
}

// MARK: UI Methods.
extension PXOneTapSheetViewController {
    fileprivate func setupUI() {
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)

        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        PXLayout.centerHorizontally(view: popupView).isActive = true
        PXLayout.setHeight(owner: popupView, height: popUpViewHeight).isActive = true
        PXLayout.pinLeft(view: popupView, withMargin: borderMargin).isActive = true
        PXLayout.pinRight(view: popupView, withMargin: borderMargin).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popUpViewHeight + borderMargin)
        bottomConstraint.isActive = true
    }
}

// MARK: Components Builders.
extension PXOneTapSheetViewController {
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

    private func getFooterView() -> UIView {
        let payAction = PXComponentAction(label: "Pagar".localized) { [weak self] in
            self?.confirmPayment()
        }
        let footerProps = PXFooterProps(buttonAction: payAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        return footerComponent.oneTapRender()
    }
}

// Sheet
extension PXOneTapSheetViewController {

    fileprivate func presentSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
            self.blurView.alpha = 1
        }) { (true) in
            self.animatePopUpView(isDeployed: false)
        }
    }

    @objc func hideSheet() {
        animatePopUpView(isDeployed: true)
    }

    @objc func fadeOut() {

        let initialFrame = CGRect(x: 0, y: 0, width: PXLayout.getScreenWidth(), height: 0)
        let animatedHeaderView: UIView = UIView(frame: initialFrame)
        animatedHeaderView.backgroundColor = ThemeManager.shared.getMainColor()
        popupView.addSubview(animatedHeaderView)

        if #available(iOS 10.0, *) {

            var height: CGFloat = 153
            if PXLayout.getSafeAreaTopInset() > 0 {
                height = 177
            }
            let finalFrame = CGRect(x: 0, y: 0, width: PXLayout.getScreenWidth(), height: height)
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1, animations: {
                animatedHeaderView.frame = finalFrame
            })

            transitionAnimator.addCompletion { _ in
                UIView.animate(withDuration: 0.4, animations: {
                    self.view.alpha = 0
                }) { finish in
                    self.dismiss(animated: false, completion: nil)
                }
            }

            transitionAnimator.startAnimation()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 0
            }) { finish in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

    fileprivate func animatePopUpView(isDeployed: Bool) {
        if #available(iOS 10.0, *) {
            var bottomContraint = 0 - self.borderMargin
            if isDeployed {
                bottomContraint = self.borderMargin + popUpViewHeight
            }
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1, animations: {
                self.bottomConstraint.constant = bottomContraint
                self.view.layoutIfNeeded()
            })

            transitionAnimator.addCompletion { position in
                if isDeployed {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.blurView.alpha = 0
                    }, completion: { finish in
                        self.dismiss(animated: false, completion: nil)
                    })
                }
            }

            transitionAnimator.startAnimation()

        } else {
            // TODO: Fallback on earlier versions
        }
    }

    fileprivate func expandSheet() {

        self.popupView.layer.masksToBounds = true

        if #available(iOS 10.0, *) {

            let targetFrame = view.frame

            let transitionAnimator = UIViewPropertyAnimator(duration: 0.60, dampingRatio: 1.3, animations: {
                self.popupView.frame = targetFrame
                self.popupView.layer.cornerRadius = 0
            })

            transitionAnimator.addCompletion({ [weak self] _ in

            })

            transitionAnimator.startAnimation()

        } else {
            // TODO: Fallback on earlier versions
        }
    }
}

// MARK: User Actions.
extension PXOneTapSheetViewController {
    @objc func shouldOpenSummary() {
        /*
        if let summaryProps = viewModel.getSummaryProps(), summaryProps.count > 0 {
            let summaryViewController = PXOneTapSummaryModalViewController()
            summaryViewController.setProps(summaryProps: viewModel.getSummaryProps())
            PXComponentFactory.Modal.show(viewController: summaryViewController, title: nil)
        }*/
    }

    @objc func shouldChangePaymentMethod() {
        //viewModel.trackChangePaymentMethodEvent()
        //callbackPaymentData(viewModel.getClearPaymentData())
    }

    fileprivate func confirmPayment() {
        //self.viewModel.trackConfirmActionEvent()
        //self.callbackConfirm(self.viewModel.paymentData)
    }

    fileprivate func cancelPayment() {
        //self.callbackExit()
    }
}
