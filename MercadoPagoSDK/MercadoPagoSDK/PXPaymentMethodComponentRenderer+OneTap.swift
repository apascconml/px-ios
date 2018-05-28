//
//  PXPaymentMethodComponentRenderer+OneTap.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXPaymentMethodComponentRenderer {
    func oneTapRender(component: PXPaymentMethodComponent) -> PXOneTapPaymentMethodView {
        let arrowImage: UIImage? = MercadoPago.getImage("oneTapArrow")
        var defaultHeight: CGFloat = 80
        let leftRightMargin = PXLayout.S_MARGIN
        let interMargin = PXLayout.S_MARGIN
        let pmView = PXOneTapPaymentMethodView()
        let cftColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.3) // Not in MLUI

        // PamentMethod Icon.
        let paymentMethodIcon = component.getPaymentMethodIconComponent()
        pmView.paymentMethodIcon = paymentMethodIcon.render()
        pmView.paymentMethodIcon?.layer.cornerRadius = IMAGE_WIDTH/2
        if let pmIcon = pmView.paymentMethodIcon {
            pmView.addSubview(pmIcon)
            PXLayout.pinLeft(view: pmIcon, withMargin: leftRightMargin).isActive = true
            PXLayout.setHeight(owner: pmIcon, height: IMAGE_HEIGHT).isActive = true
            PXLayout.setWidth(owner: pmIcon, width: IMAGE_WIDTH).isActive = true
            PXLayout.pinTop(view: pmIcon, to: pmView, withMargin: PXLayout.S_MARGIN).isActive = true
        }

        // PamentMethod Title.
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        pmView.paymentMethodTitle = title
        pmView.addSubview(title)
        title.attributedText = component.props.title
        title.font = Utils.getFont(size: PXLayout.XS_FONT)
        title.textColor = component.props.boldLabelColor
        title.textAlignment = .left
        title.numberOfLines = 1
        if let pmTitle = pmView.paymentMethodTitle, let pmIcon = pmView.paymentMethodIcon {
            PXLayout.put(view: pmTitle, rightOf: pmIcon, withMargin: interMargin).isActive = true
            PXLayout.pinRight(view: pmTitle, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: pmTitle, height: PXLayout.L_FONT).isActive = true
        }

        // PaymentMethod Subtitle.
        if let detailText = component.props.subtitle, let pmTitle = pmView.paymentMethodTitle, let pmIcon = pmView.paymentMethodIcon {
            let detailLabel = UILabel()
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            pmView.addSubview(detailLabel)
            detailLabel.attributedText = detailText
            detailLabel.font = Utils.getFont(size: PXLayout.XXS_FONT)
            detailLabel.textColor = component.props.lightLabelColor
            detailLabel.textAlignment = .left
            PXLayout.setHeight(owner: detailLabel, height: PXLayout.M_FONT).isActive = true
            PXLayout.pinLeft(view: detailLabel, to: pmTitle).isActive = true
            PXLayout.pinTop(view: pmTitle, to: pmIcon, withMargin: PXLayout.XXXS_MARGIN).isActive = true
            PXLayout.pinBottom(view: detailLabel, to: pmIcon, withMargin: PXLayout.XXXS_MARGIN).isActive = true
            PXLayout.setWidth(owner: detailLabel, width: detailLabel.intrinsicContentSize.width).isActive = true
            pmView.paymentMethodSubtitle = detailLabel
        } else {
            if let pmTitle = pmView.paymentMethodTitle {
                PXLayout.centerVertically(view: pmTitle, to: pmView).isActive = true
            }
        }

        // Arrow image.
        if let pmIcon = pmView.paymentMethodIcon {
            let arrowImageView = UIImageView(image: arrowImage)
            arrowImageView.contentMode = .scaleAspectFit
            pmView.addSubview(arrowImageView)
            PXLayout.setHeight(owner: arrowImageView, height: PXLayout.XS_MARGIN).isActive = true
            PXLayout.setWidth(owner: arrowImageView, width: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.centerVertically(view: arrowImageView, to: pmIcon).isActive = true
            PXLayout.pinRight(view: arrowImageView, withMargin: PXLayout.S_MARGIN).isActive = true
        }

        // No interest label.
        if let noInterestAttr = component.props.descriptionTitle, let subtitleLabel = pmView.paymentMethodSubtitle {
            let noInterestLabel = UILabel()
            noInterestLabel.translatesAutoresizingMaskIntoConstraints = false
            pmView.addSubview(noInterestLabel)
            noInterestLabel.attributedText = noInterestAttr
            noInterestLabel.font = Utils.getFont(size: PXLayout.XXS_FONT)
            noInterestLabel.textColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
            noInterestLabel.textAlignment = .left
            PXLayout.setHeight(owner: noInterestLabel, height: PXLayout.M_FONT).isActive = true
            PXLayout.centerVertically(view: noInterestLabel, to: subtitleLabel).isActive = true
            PXLayout.put(view: noInterestLabel, rightOf: subtitleLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true

            // CFT label.
            if let cftAttr = component.props.descriptionDetail {
                let cftLabel = UILabel()
                cftLabel.translatesAutoresizingMaskIntoConstraints = false
                pmView.addSubview(cftLabel)
                cftLabel.attributedText = cftAttr
                cftLabel.font = Utils.getFont(size: PXLayout.M_FONT)
                cftLabel.textColor = cftColor
                cftLabel.textAlignment = .left
                PXLayout.setHeight(owner: cftLabel, height: PXLayout.M_FONT).isActive = true
                PXLayout.pinLeft(view: cftLabel, to: subtitleLabel, withMargin: 0).isActive = true
                PXLayout.pinBottom(view: cftLabel, to: pmView, withMargin: PXLayout.S_MARGIN).isActive = true
                defaultHeight += PXLayout.M_MARGIN
            }
        }

        // Bordered line color.
        pmView.layer.borderWidth = 1
        pmView.layer.borderColor = ThemeManager.shared.lightTintColor().cgColor
        pmView.layer.cornerRadius = 4
        pmView.backgroundColor = component.props.backgroundColor
        pmView.translatesAutoresizingMaskIntoConstraints = false

        PXLayout.setHeight(owner: pmView, height: defaultHeight).isActive = true
        return pmView
    }
}