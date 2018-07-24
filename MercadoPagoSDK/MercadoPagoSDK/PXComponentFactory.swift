//
//  PXComponentFactory.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 7/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLUI

struct PXComponentFactory {

    struct Modal {
        static func show(viewController: UIViewController, title: String?) -> MLModal? {
            if let modalTitle = title {
                return MLModal.show(with: viewController, title: modalTitle)
            } else {
                return MLModal.show(with: viewController)
            }
        }

        static func show(viewController: UIViewController, title: String?, dismissBlock: @escaping (() -> Void)) -> MLModal? {
            if let modalTitle = title {
                return MLModal.show(with: viewController, title: modalTitle, actionTitle: "", actionBlock: {}, secondaryActionTitle: "", secondaryActionBlock: {}, dismiss: dismissBlock, enableScroll: false)
            } else {
                return MLModal.show(with: viewController, dismiss: dismissBlock)
            }
        }
    }

    struct Loading {
        static func instance() -> PXLoadingComponent {
            return PXLoadingComponent.shared
        }
    }

    struct Spinner {
        static func new(color1: UIColor, color2: UIColor) -> MLSpinner {
            let spinnerConfig = MLSpinnerConfig(size: .big, primaryColor: color1, secondaryColor: color2)
            return MLSpinner(config: spinnerConfig, text: nil)
        }

        static func newSmall(color1: UIColor, color2: UIColor) -> MLSpinner {
            let spinnerConfig = MLSpinnerConfig(size: .small, primaryColor: color1, secondaryColor: color2)
            return MLSpinner(config: spinnerConfig, text: nil)
        }
    }

    struct SnackBar {
        static func showShortDurationMessage(message: String) {
            MLSnackbar.show(withTitle: message, type: .default(), duration: .short)
        }

        static func showLongDurationMessage(message: String) {
            MLSnackbar.show(withTitle: message, type: .default(), duration: .long)
        }

        static func showPersistentMessage(message: String) {
            MLSnackbar.show(withTitle: message, type: .default(), duration: .indefinitely)
        }
    }
}
