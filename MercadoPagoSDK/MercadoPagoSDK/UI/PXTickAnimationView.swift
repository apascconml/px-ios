//
//  PXTickAnimationView.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 27/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXTickAnimationView: UIView {

    private weak var shapeLayer: CAShapeLayer?
    private let animationKey: String = "PXTick"
    private let color: UIColor = .white

    static func getSize() -> (width: Double, height: Double) {
        return (20, 18)
    }

    func animate(duration: Double = 0.8, lineWidth: CGFloat = 2.8) {
        shapeLayer?.removeFromSuperlayer()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.5, y: 8.14))
        path.addLine(to: CGPoint(x: 7.45, y: 14.5))
        path.addLine(to: CGPoint(x: 18.5, y: 0.5))

        let shape = CAShapeLayer()
        shape.fillColor = nil
        shape.strokeColor = color.cgColor
        shape.lineWidth = lineWidth
        shape.path = path.cgPath

        backgroundColor = UIColor.clear
        layer.addSublayer(shape)

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = duration
        shape.add(animation, forKey: animationKey)
        shapeLayer = shape
    }
}
