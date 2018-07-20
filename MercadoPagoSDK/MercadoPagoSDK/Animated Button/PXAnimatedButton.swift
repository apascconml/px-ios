//
//  PXAnimatedButton.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 27/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import AVFoundation

protocol PXAnimatedButtonDelegate: NSObjectProtocol {
    func expandAnimationInProgress()
    func didFinishAnimation()
    func progressButtonAnimationTimeOut()
    func shakeDidFinish()
}

internal class PXAnimatedButton: UIButton {
    weak var animationDelegate: PXAnimatedButtonDelegate?
    var progressView: ProgressView?
    var status: Status = .normal

    enum FinishStyle: Int {
        case warning
        case success
        case error
    }

    enum Status {
        case normal
        case loading
        case expanding
        case shaking
    }
}

extension PXAnimatedButton: ProgressViewDelegate, CAAnimationDelegate {
    func startLoading(loadingText: String, retryText: String, timeOut: TimeInterval = 15.0) {
        progressView = ProgressView(forView: self, loadingColor: #colorLiteral(red: 0.03, green: 0.33, blue: 0.85, alpha: 1.0), timeOut: timeOut)
        progressView?.progressDelegate = self
        setTitle(loadingText, for: .normal)
        status = .loading
    }

    func finishAnimatingButton(style: FinishStyle) {
        status = .expanding
        let color: UIColor = getColor(style: style)
        let image = getImage(style: style)

        let newFrame = CGRect(x: self.frame.midX - self.frame.height / 2, y: self.frame.midY - self.frame.height / 2, width: self.frame.height, height: self.frame.height)

        progressView?.doComplete(completion: { success in

            UIView.animate(withDuration: 0.5,
                           animations: {
                            self.setTitle("", for: .normal)
                            self.frame = newFrame
                            self.layer.cornerRadius = self.frame.height / 2
            },
                           completion: { _ in

                            UIView.animate(withDuration: 0.3, animations: {
                                self.progressView?.alpha = 0
                                self.backgroundColor = color
                            }, completion: { _ in

                                let scaleFactor: CGFloat = 0.40
                                let iconImage = UIImageView(frame: CGRect(x: newFrame.width / 2 - (newFrame.width * scaleFactor) / 2, y: newFrame.width / 2 - (newFrame.width * scaleFactor) / 2, width: newFrame.width * scaleFactor, height: newFrame.height * scaleFactor))

                                iconImage.image = image
                                iconImage.contentMode = .scaleAspectFit
                                iconImage.alpha = 0

                                self.addSubview(iconImage)

                                // Ver que hacer en los otros casos
                                if style == .success {
                                    if #available(iOS 10.0, *) {
                                        let notification = UINotificationFeedbackGenerator()
                                        notification.notificationOccurred(.success)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }

                                UIView.animate(withDuration: 0.6, animations: {
                                    iconImage.alpha = 1
                                    iconImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                                }) { _ in

                                    UIView.animate(withDuration: 0.4, animations: {
                                        iconImage.alpha = 0
                                    }, completion: { _ in

                                        self.superview?.layer.masksToBounds = false
                                        self.animationDelegate?.expandAnimationInProgress()
                                        UIView.animate(withDuration: 0.5, animations: {
                                            self.transform = CGAffineTransform(scaleX: 50, y: 50)
                                        }, completion: { _ in
                                            self.animationDelegate?.didFinishAnimation()
                                        })
                                    })
                                }
                            })
            })
        })
    }

    @objc func animateFinishSuccess() {
        finishAnimatingButton(style: .success)
    }

    @objc func animateFinishError() {
        finishAnimatingButton(style: .error)
    }

    @objc func animateFinishWarning() {
        finishAnimatingButton(style: .warning)
    }

    func didFinishProgress() {
        progressView?.doReset()
    }

    func shake() {
        status = .shaking
        resetButton()
        setTitle("Reintentar".localized, for: .normal)
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundColor = ThemeManager.shared.rejectedColor()
        }, completion: { _ in
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.1
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 3, y: self.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 3, y: self.center.y))

            CATransaction.setCompletionBlock {
                self.isUserInteractionEnabled = true
                self.animationDelegate?.shakeDidFinish()
                self.status = .normal
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundColor = ThemeManager.shared.getAccentColor()
                })
            }
            self.layer.add(animation, forKey: "position")

            CATransaction.commit()
        })
    }

    func progressTimeOut() {
        progressView?.doReset()
        animationDelegate?.progressButtonAnimationTimeOut()
    }

    func resetButton() {
        progressView?.stopTimer()
        progressView?.doReset()
    }

    func isAnimated() -> Bool {
        return status != .normal
    }
}

extension PXAnimatedButton {
    func getColor(style: FinishStyle) -> UIColor {
        switch style {
        case .success:
            return ThemeManager.shared.successColor()
        case .error:
            return ThemeManager.shared.rejectedColor()
        case .warning:
            return ThemeManager.shared.warningColor()
        }
    }

    func getImage(style: FinishStyle) -> UIImage? {
        switch style {
        case .success:
            return MercadoPago.getImage("one_tap_button_check")
        case .error:
            return MercadoPago.getImage("one_tap_button_error")
        case .warning:
            return MercadoPago.getImage("one_tap_button_error")
        }
    }
}
