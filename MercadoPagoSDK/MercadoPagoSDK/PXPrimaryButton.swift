//
//  PXPrimaryButton.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 9/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLUI
import AVFoundation

protocol PXAnimatedButtonDelegate: NSObjectProtocol {
    func expandAnimationInProgress()
    func didFinishAnimation()
}

internal class PXPrimaryButton: MLButton {

    weak var animationDelegate: PXAnimatedButtonDelegate?
    var progressView: PXPogressView?

    override init() {
        let config = MLButtonStylesFactory.config(for: .primaryAction)
        super.init(config: config)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PXPrimaryButton {
    func startLoading(loadingText:String, retryText:String) {
        progressView = PXPogressView(forView: self)
        progressView?.start(timeOutBlock: {
            // This is temporary. Only for now, without real payment.
            /*
             isUserInteractionEnabled = true
             self.setTitle(retryText, for: .normal)
             self.progressView?.doReset()
             */
            self.progressView?.doReset()
            self.animateFinishSuccess()
        })

        buttonTitle = loadingText
        isUserInteractionEnabled = false
    }

    func animateFinishSuccess() {

        let successColor = ThemeManager.shared.successColor()
        let successCheckImage = MercadoPago.getImage("success_image")

        let newFrame = CGRect(x: self.frame.midX-self.frame.height/2, y: self.frame.midY-self.frame.height/2, width: self.frame.height , height: self.frame.height)

        var expandAnimationNotified = false

        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.isUserInteractionEnabled = false
                        self.buttonTitle = ""
                        self.frame = newFrame
                        self.layer.cornerRadius = self.frame.height/2
        },
                       completion: { _ in

                        UIView.animate(withDuration: 0.3, animations: {
                            self.backgroundColor = successColor
                        }, completion: { _ in

                            let scaleFactor: CGFloat = 0.40
                            let successImage = UIImageView(frame: CGRect(x: newFrame.width/2 - (newFrame.width*scaleFactor)/2, y: newFrame.width/2 - (newFrame.width*scaleFactor)/2, width: newFrame.width*scaleFactor, height:newFrame.height*scaleFactor))

                            successImage.image = successCheckImage
                            successImage.contentMode = .scaleAspectFit
                            successImage.alpha = 0

                            self.addSubview(successImage)

                            let systemSoundID: SystemSoundID = 1109
                            AudioServicesPlaySystemSound(systemSoundID)

                            if #available(iOS 10.0, *) {
                                let notification = UINotificationFeedbackGenerator()
                                notification.notificationOccurred(.success)
                            } else {
                                // Fallback on earlier versions
                            }

                            UIView.animate(withDuration: 0.6, animations: {
                                successImage.alpha = 1
                                successImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                            }) { _ in

                                UIView.animate(withDuration: 0.4, animations: {
                                    successImage.alpha = 0
                                }, completion: { _ in

                                    self.superview?.layer.masksToBounds = false

                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.transform = CGAffineTransform(scaleX: 50, y: 50)
                                        if !expandAnimationNotified {
                                            expandAnimationNotified = true
                                            self.animationDelegate?.expandAnimationInProgress()
                                        }
                                    }, completion: { _ in
                                        self.animationDelegate?.didFinishAnimation()
                                    })
                                })
                            }
                        })
        })
    }
}
