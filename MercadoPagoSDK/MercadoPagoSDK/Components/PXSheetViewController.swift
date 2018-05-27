//
//  PXSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 27/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

internal protocol PXSheetDelegate: NSObjectProtocol {
    func contentViewForSheet() -> UIView
    func contentTopMargin() -> CGFloat
    func contentBottomMargin() -> CGFloat
    func titleForSheet() -> String?
}

class PXSheetViewController: UIViewController, PXSheetDelegate {
    private var popUpViewHeight: CGFloat = 0
    private let borderMargin = PXLayout.XXXS_MARGIN
    private var blurView: UIVisualEffectView = UIVisualEffectView()
    private var bottomConstraint = NSLayoutConstraint()
    lazy var popupView: UIView = UIView()
    weak var sheetDelegate: PXSheetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetDelegate = self
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheet()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView = createPopup(cView: sheetDelegate?.contentViewForSheet())
        view.addSubview(popupView)
        PXLayout.centerHorizontally(view: popupView).isActive = true
        PXLayout.setHeight(owner: popupView, height: popUpViewHeight).isActive = true
        PXLayout.pinLeft(view: popupView, withMargin: borderMargin).isActive = true
        PXLayout.pinRight(view: popupView, withMargin: borderMargin).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popUpViewHeight + borderMargin)
        bottomConstraint.isActive = true
    }

    func contentViewForSheet() -> UIView {
        fatalError("PXSheetViewController - Override contentViewForSheet()")
    }

    func titleForSheet() -> String? {
        fatalError("PXSheetViewController - Override titleForSheet()")
    }

    func contentTopMargin() -> CGFloat {
        return 0
    }

    func contentBottomMargin() -> CGFloat {
        return PXLayout.getSafeAreaBottomInset()
    }

    private func createPopup(cView: UIView?) -> UIView {
        let view = UIView()
        let boldColor: UIColor = ThemeManager.shared.boldLabelTintColor()
        let closeButtonImage = MercadoPago.getImage("oneTapClose")
        let closeButtonColor: UIColor = ThemeManager.shared.labelTintColor()

        let RADIUS_WITH_SAFE_AREA: CGFloat = 32
        let RADIUS_WITHOUT_SAFE_AREA: CGFloat = 15
        let TITLE_VIEW_HEIGHT: CGFloat = 58

        var estimatedHeight: CGFloat = 0

        if PXLayout.getSafeAreaTopInset() > 0 {
            view.layer.cornerRadius = RADIUS_WITH_SAFE_AREA
        } else {
            view.layer.cornerRadius = RADIUS_WITHOUT_SAFE_AREA
        }

        view.clipsToBounds = true
        view.backgroundColor = UIColor.white

        // Title
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        PXLayout.matchWidth(ofView: titleView).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.pinTop(view: titleView).isActive = true
        PXLayout.setHeight(owner: titleView, height: TITLE_VIEW_HEIGHT).isActive = true

        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .UIColorFromRGB(0xEEEEEE)
        titleView.addSubview(line)
        PXLayout.pinBottom(view: line).isActive = true
        PXLayout.matchWidth(ofView: line).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: 1).isActive = true

        let titleLabel = UILabel()
        titleView.addSubview(titleLabel)
        PXLayout.centerHorizontally(view: titleLabel).isActive = true
        PXLayout.matchWidth(ofView: titleLabel).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true
        PXLayout.setHeight(owner: titleLabel, height: TITLE_VIEW_HEIGHT).isActive = true
        titleLabel.text = sheetDelegate?.titleForSheet()
        titleLabel.font = UIFont.systemFont(ofSize: PXLayout.XXL_FONT, weight: UIFont.Weight.thin)
        titleLabel.textColor = boldColor
        titleLabel.textAlignment = .center

        //Cancel button
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.add(for: .touchUpInside, { [weak self] in
            self?.hideSheet()
        })
        button.setImage(closeButtonImage, for: .normal)
        button.tintColor = closeButtonColor
        titleView.addSubview(button)
        PXLayout.pinRight(view: button, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setWidth(owner: button, width: 50).isActive = true
        PXLayout.setHeight(owner: button, height: 30).isActive = true

        // Add external content view.
        if let containerView = cView {
            view.addSubview(containerView)
            PXLayout.matchWidth(ofView: containerView).isActive = true
            PXLayout.centerHorizontally(view: containerView).isActive = true
            for sView in containerView.subviews {
                sView.layoutIfNeeded()
                estimatedHeight += sView.bounds.height
            }
            if let topMargin = sheetDelegate?.contentTopMargin() {
                estimatedHeight += topMargin
                PXLayout.put(view: containerView, onBottomOf: titleView, withMargin: topMargin).isActive = true
            } else {
                PXLayout.put(view: containerView, onBottomOf: titleView).isActive = true
            }
            PXLayout.setHeight(owner: containerView, height: estimatedHeight).isActive = true
        }

        view.layoutIfNeeded()

        var bottomMargin = PXLayout.getSafeAreaBottomInset()
        if let bottomContentMargin = sheetDelegate?.contentBottomMargin() {
            bottomMargin = bottomContentMargin
        }
        popUpViewHeight += TITLE_VIEW_HEIGHT + estimatedHeight + bottomMargin
        return view
    }

    func presentSheet() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.alpha = 1
            self?.blurView.alpha = 1
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

    func animatePopUpView(isDeployed: Bool) {
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
            // No support < iOS 10.
        }
    }

    func expandSheet() {
        let defaultStatusOffset: CGFloat = 22
        var topMarginDelta = PXLayout.getSafeAreaTopInset()
        if topMarginDelta == 0 {
            topMarginDelta = defaultStatusOffset
        }
        popupView.layer.masksToBounds = true
        if #available(iOS 10.0, *) {
            let targetFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + topMarginDelta, width: view.frame.width, height: view.frame.height - topMarginDelta)
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.60, dampingRatio: 1.4, animations: {
                self.popupView.frame = targetFrame
            })
            transitionAnimator.startAnimation()
        } else {
            // No support < iOS 10.
        }
    }
}
