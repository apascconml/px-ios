//
//  PXTimerComponent.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 28/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

struct PXTimerComponent {
    let timerLabel: UILabel
    init(timerDisplayValue: String, yPosition: CGFloat) {
        timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        timerLabel.text = timerDisplayValue
        timerLabel.backgroundColor = UIColor(red: 0.21, green: 0.20, blue: 0.20, alpha: 0.8)
        timerLabel.textColor = .white
        let newSize: CGSize = timerDisplayValue.size(attributes: [NSFontAttributeName: timerLabel.font])
        timerLabel.frame = CGRect(x: UIScreen.main.bounds.width - newSize.width - 8, y: yPosition, width: newSize.width + 2, height: newSize.height)
        timerLabel.isHidden = true
    }
    func render() -> UIView {
        return timerLabel
    }
    func updateValue(timerValue: String) {
        timerLabel.isHidden = false
        timerLabel.text = timerValue
        let newSize: CGSize = timerValue.size(attributes: [NSFontAttributeName: timerLabel.font])
        timerLabel.frame.size = newSize
    }
}
