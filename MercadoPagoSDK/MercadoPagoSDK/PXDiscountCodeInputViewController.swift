//
//  PXDiscountCodeInputViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServicesV4
import MLUI

final class PXDiscountCodeInputViewController: MercadoPagoUIViewController, MLTitledTextFieldDelegate {

    override open var screenName: String { return "DISCOUNT_SUMMARY" }

    let contentView: PXComponentView = PXComponentView()
    private var textfield: MLTitledSingleLineTextField?
    private var spinner: MLSpinner?
    private var discountValidationCallback:  (PXDiscount, PXCampaign, @escaping ()->Void, @escaping ()->Void) -> Void
    private var closeModalCallback: (() -> Void)!

    init(discountValidationCallback: @escaping (PXDiscount, PXCampaign, @escaping ()->Void, @escaping ()->Void) -> Void, closeModalCallback: @escaping (() -> Void)) {
        self.discountValidationCallback = discountValidationCallback
        self.closeModalCallback = closeModalCallback
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if self.contentView.isEmpty() {
            renderViews()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.textfield!.becomeFirstResponder()
        })
    }
}

// MARK: Render Views
extension PXDiscountCodeInputViewController {

    private func renderViews() {
        let TITLE_LABEL_HEIGHT: CGFloat = 30

        //Build title
        if let title = getTitle() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.attributedText = title
            self.contentView.addSubviewToBottom(label, withMargin: PXLayout.XL_MARGIN)
            PXLayout.centerHorizontally(view: label).isActive = true
            PXLayout.pinLeft(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: label, height: TITLE_LABEL_HEIGHT).isActive = true
        }

        //Build input textfield
        let textfield = MLTitledSingleLineTextField()
        self.textfield = textfield
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        textfield.autocapitalizationType = .allCharacters
//        textfield.autocorrectionType = UITextAutocorrectionType.no


//        textfield.textInputControl().autocorrectionType = UITextAutocorrectionType.no


        self.contentView.addSubviewToBottom(textfield, withMargin: PXLayout.XXL_MARGIN)
        PXLayout.centerHorizontally(view: textfield).isActive = true
        PXLayout.pinLeft(view: textfield, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.pinRight(view: textfield, withMargin: PXLayout.M_MARGIN).isActive = true

        //Spinner
        let spinner = PXComponentFactory.Spinner.newSmall(color1: ThemeManager.shared.secondaryColor(), color2: ThemeManager.shared.secondaryColor())
        self.spinner = spinner
        self.contentView.addSubview(spinner)
        PXLayout.pinRight(view: spinner, to: textfield, withMargin: 5).isActive = true
        PXLayout.pinTop(view: spinner, to: textfield, withMargin: 10).isActive = true

        //Build action button
        let button = PXPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonTitle = "Continuar"
        self.contentView.addSubview(button)
        PXLayout.put(view: button, onBottomOf: textfield, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.centerHorizontally(view: button).isActive = true
        PXLayout.pinLeft(view: button, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.pinRight(view: button, withMargin: PXLayout.M_MARGIN).isActive = true
        button.add(for: .touchUpInside) {
            if textfield.text.isNotEmpty {
                self.getCodeDiscount(with: textfield.text)
            } else {
                self.showError(with: "Complete este campo")
            }
        }

        self.contentView.pinLastSubviewToBottom(withMargin: PXLayout.M_MARGIN)?.isActive = true
        self.view.addSubview(contentView)
        PXLayout.matchWidth(ofView: contentView).isActive = true
        PXLayout.matchHeight(ofView: contentView).isActive = true
        PXLayout.centerHorizontally(view: contentView).isActive = true
        PXLayout.centerVertically(view: contentView).isActive = true
    }

    private func getTitle() -> NSAttributedString? {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let activeDiscountAttributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.L_FONT),
                                        NSAttributedStringKey.foregroundColor: ThemeManager.shared.boldLabelTintColor(),
                                        NSAttributedStringKey.paragraphStyle: paragraph]

        let string = "Ingresa tu cupón"
        let attributedString = NSMutableAttributedString(string: string, attributes: activeDiscountAttributes)
        return attributedString
    }

    private func getErrorMessage() -> String {
        return "Revisa este dato"
    }

    private func showError(with text: String) {
        if let textfield = textfield {
            textfield.errorDescription = text
        }
    }

    private func transitionToSuccess(with discount: PXDiscount) {

        self.textfield?.resignFirstResponder()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let successView = self.buildPXDiscountCodeInputSuccessView(with: discount, frame: self.view.frame)
            self.view.backgroundColor = .white
            successView.backgroundColor = .white
            self.view.superview?.backgroundColor = .clear
            self.view.superview?.superview?.backgroundColor = .clear
            self.view.superview?.superview?.superview?.backgroundColor = .clear

            UIView.transition(from: self.view, to: successView, duration: 0.5, options: .transitionFlipFromRight, completion: nil)
        })
    }

    func buildPXDiscountCodeInputSuccessView(with discount: PXDiscount, frame: CGRect) -> PXDiscountCodeInputSuccessView {
        let view = PXDiscountCodeInputSuccessView(frame: self.view.frame)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let titleAttributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.L_FONT),
                               NSAttributedStringKey.foregroundColor: ThemeManager.shared.boldLabelTintColor(),
                               NSAttributedStringKey.paragraphStyle: paragraph]

        let messageAttributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XS_FONT),
                                 NSAttributedStringKey.foregroundColor: ThemeManager.shared.labelTintColor(),
                                 NSAttributedStringKey.paragraphStyle: paragraph]

        let titleString = "¡Excelente!"
        let titleAttributedString = NSMutableAttributedString(string: titleString, attributes: titleAttributes)

        let discountDescription = discount.getDiscountDescription()
        let messageString = "Ahora paga tu compra y obtén \(discountDescription) de descuento."
        let messageAttributedString = NSMutableAttributedString(string: messageString, attributes: messageAttributes)

        let image = MercadoPago.getImage("codeInputSuccess")

        let action = PXComponentAction(label: "Continuar") {
            self.closeModalCallback()
        }

        view.setProps(title: titleAttributedString, message: messageAttributedString, icon: image!, action: action)
        return view
    }
}

// MARK: Services
extension PXDiscountCodeInputViewController {

    func getCodeDiscount(with code: String) {
        if let mercadoPagoCheckout = MercadoPagoCheckout.currentCheckout {
            self.spinner?.show()
            mercadoPagoCheckout.viewModel.mercadoPagoServicesAdapter.getCodeDiscount(amount: mercadoPagoCheckout.viewModel.amountHelper.amountToPay, payerEmail: mercadoPagoCheckout.viewModel.checkoutPreference.payer.email, couponCode: code, callback: { [weak self] (discount) in

                guard let strongSelf = self else {
                    return
                }

                if let discount = discount, let campaigns = mercadoPagoCheckout.viewModel.campaigns {
                    let filteredCampaigns = campaigns.filter { (campaign: PXCampaign) -> Bool in
                        return campaign.id.stringValue == discount.id
                    }
                    if let firstFilteredCampaign = filteredCampaigns.first {
                        strongSelf.discountValidationCallback(discount, firstFilteredCampaign, {
                            strongSelf.spinner?.hide()
                            strongSelf.transitionToSuccess(with: discount)
                        }, {
                            strongSelf.spinner?.hide()
                            strongSelf.showError(with: "grupos fallo")
                        })
                    }
                }

                }, failure: { [weak self] _ in

                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.spinner?.hide()
                    strongSelf.showError(with: strongSelf.getErrorMessage())
            })
        }
    }
}