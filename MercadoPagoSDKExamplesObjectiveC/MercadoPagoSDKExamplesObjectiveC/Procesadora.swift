//
//  Procesadora.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 13/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

@objc class Procesadora: NSObject, PXPaymentPluginComponent {
    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        return UIView()
    }
    var navHandler : PXPluginNavigationHandler!
    func navigationHandlerForPlugin(navigationHandler: PXPluginNavigationHandler){
        self.navHandler = navigationHandler
    }
    func viewWillAppear() {
        navHandler.didFinishPayment(status: "approved", statusDetail: "approved")
    }
    func support(pluginStore: PXCheckoutStore) -> Bool {
       return  true
    }
    func paymentPreprocess(pluginStore: PXCheckoutStore) -> [SummaryItemDetail] // TODO COMISIONES
    {
        var fees = [SummaryItemDetail]()
        if let pm = pluginStore.getPaymentData().paymentMethod {
            if pm.isOnlinePaymentMethod {
                fees.append(SummaryItemDetail(name:"cargos", amount: 100.0))
                 fees.append(SummaryItemDetail(name:"descuento", amount: -60.0))
            }
        }
     return fees
    }
}
