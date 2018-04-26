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
    struct suscribeTo {
        static func attempToClose(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer)
            notificationCenter.addObserver(observer, selector: selector, name: .attempToClose, object: nil)
        }
    }
}

extension PXNotificationManager {
    struct post  {
        static func attempToClose() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .attempToClose, object: nil)
        }
    }
}

internal extension NSNotification.Name {
      static let attempToClose = Notification.Name(rawValue:"PXAttempToClose")
}
