//
//  PXNotificationManager.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 25/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

struct PXNotificationManager {

}

extension PXNotificationManager {
    struct SuscribeTo {
        static func attemptToClose(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .attemptToClose, object: nil)
        }

        static func animateButtonForSuccess(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .animateButtonForSuccess, object: nil)
        }

        static func animateButtonForError(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .animateButtonForError, object: nil)
        }

        static func animateButtonForWarning(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .animateButtonForWarning, object: nil)
        }
    }
}

extension PXNotificationManager {
    struct UnsuscribeTo {
        static func attemptToClose(_ observer: Any) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .attemptToClose, object: nil)
        }

        static func animateButtonForSuccess(_ observer: Any?) {
            guard let observer = observer else {
                return
            }
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .animateButtonForSuccess, object: nil)
        }

        static func animateButtonForError(_ observer: Any?) {
            guard let observer = observer else {
                return
            }
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .animateButtonForError, object: nil)
        }

        static func animateButtonForWarning(_ observer: Any?) {
            guard let observer = observer else {
                return
            }
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .animateButtonForWarning, object: nil)
        }
    }
}

extension PXNotificationManager {
    struct Post {
        static func attemptToClose() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .attemptToClose, object: nil)
        }

        static func animateButtonForSuccess() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .animateButtonForSuccess, object: nil)
        }

        static func animateButtonForError() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .animateButtonForError, object: nil)
        }

        static func animateButtonForWarning() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .animateButtonForWarning, object: nil)
        }
    }
}

internal extension NSNotification.Name {
    static let attemptToClose = Notification.Name(rawValue: "PXAttemptToClose")
    static let animateButtonForSuccess = Notification.Name(rawValue: "PXAnimateButtonForSucces")
    static let animateButtonForError = Notification.Name(rawValue: "PXAnimateButtonForError")
    static let animateButtonForWarning = Notification.Name(rawValue: "PXAnimateButtonForWarning")
}
