//
//  DiscountCouponTest.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class DiscountCouponTest: XCTestCase {

    let amount = 1000.0

    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("DiscountCoupon")!
        let discountFromJSON = DiscountCoupon.fromJSON(json, amountWithoutDiscount: amount)
        XCTAssertEqual(discountFromJSON, discountFromJSON)
    }

    func testToJSON() {

        let discountCoupon = DiscountCoupon(discountId: 123)
        discountCoupon.name = "discount"
        discountCoupon.percent_off = "20"
        discountCoupon.amount_off = "200"
        discountCoupon.coupon_amount = "220"
        discountCoupon.currency_id = "ARS"
        discountCoupon.concept = "concept"

        let discountJson = discountCoupon.toJSON()

        XCTAssertNotNil(discountCoupon.toJSONString())

        XCTAssertEqual(discountJson["id"] as! UInt, 123)
        XCTAssertEqual(discountJson["name"] as! String, "discount")
        XCTAssertEqual(discountJson["percent_off"] as! Int, 20)
        XCTAssertEqual(discountJson["amount_off"] as! Int, 200)
        XCTAssertEqual(discountJson["coupon_amount"] as! Int, 220)
        XCTAssertEqual(discountJson["currency_id"] as! String, "ARS")
        XCTAssertEqual(discountJson["concept"] as! String, "concept")
    }

    func testToJSONFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("DiscountCoupon")!
        let discountObject: DiscountCoupon = DiscountCoupon.fromJSON(json, amountWithoutDiscount: amount)!
        let discountObjectJSON = discountObject.toJSON() as NSDictionary

        XCTAssertEqual(json["id"] as! Int, discountObjectJSON["id"] as! Int)
        XCTAssertEqual(json["name"] as! String, discountObjectJSON["name"] as! String)
        XCTAssertEqual(json["percent_off"] as! Int, discountObjectJSON["percent_off"] as! Int)
        XCTAssertEqual(json["amount_off"] as! Int, discountObjectJSON["amount_off"] as! Int)
        XCTAssertEqual(json["coupon_amount"] as! Int, discountObjectJSON["coupon_amount"] as! Int)
        XCTAssertEqual(json["currency_id"] as! String, discountObjectJSON["currency_id"] as! String)
        XCTAssertEqual(json["concept"] as! String, discountObjectJSON["concept"] as! String)
    }

}
