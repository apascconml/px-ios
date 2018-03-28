//
//  PXTimerService.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 28/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

protocol PXTimerLifecycleDelegate: NSObjectProtocol {
    func didFinishTimer()
}

internal extension Notification.Name {
    static let updatePxTimer = Notification.Name("updatePxTimer")
}

class PXTimerService {
    
    fileprivate lazy var timer = Timer()
    fileprivate lazy var seconds: Int = 0
    fileprivate lazy var isRunning = false
    
    weak var lifecycleDelegate: PXTimerLifecycleDelegate?
    
    init(withSeconds: Int) {
        seconds = withSeconds
    }
    
    func startTimer() {
        if seconds > 0 {
            if !isRunning {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(PXTimerService.updateTimer)), userInfo: nil, repeats: true)
                isRunning = true
            }
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            lifecycleDelegate?.didFinishTimer()
        } else {
            seconds -= 1
            let newValue = getDisplayValue(forTime: TimeInterval(seconds))
            notifyTimerUpdate(timerDisplayValue: newValue)
            #if DEBUG
                print(newValue)
            #endif
        }
    }
    
    private func getDisplayValue(forTime: TimeInterval) -> String {
        let minutes = Int(forTime) / 60 % 60
        let seconds = Int(forTime) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func notifyTimerUpdate(timerDisplayValue: String) {
        NotificationCenter.default.post(name: .updatePxTimer, object: timerDisplayValue)
    }
}
