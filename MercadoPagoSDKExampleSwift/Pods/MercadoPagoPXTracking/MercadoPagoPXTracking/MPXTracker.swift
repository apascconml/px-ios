//
//  MPXTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol MPTrackListener {
    func trackScreen(screenName: String, extraParams: [String: Any]?)
    func trackEvent(screenName: String?, action: String!, result: String?, extraParams: [String: Any]?)
}

public struct MPXTrackingEnvironment {
    public static let production = "production"
    public static let staging = "staging"
}

@objc
public class MPXTracker: NSObject {
    @objc open static let sharedInstance = MPXTracker()

    var public_key: String = ""
    var sdkVersion = ""
    static let kTrackingSettings = "tracking_settings"
    fileprivate static let kTrackingEnabled = "tracking_enabled"

    @objc open var trackListener: MPTrackListener?
    var trackingStrategy: TrackingStrategy = RealTimeStrategy()

    fileprivate var flowService: FlowService = FlowService()
    fileprivate lazy var currentEnvironment: String = MPXTrackingEnvironment.production
}

// MARK: Getters/setters.
extension MPXTracker {

    open class func setPublicKey(_ public_key: String) {
        sharedInstance.public_key = public_key.trimSpaces()
    }

    open class func setSdkVersion(_ version: String) {
        sharedInstance.sdkVersion = version
    }

    open func getPublicKey() -> String! {
        return self.public_key
    }

    open func setEnvironment(environment: String) {
        self.currentEnvironment = environment
    }

    open func getSdkVersion() -> String {
        return sdkVersion
    }

    open func getPlatformType() -> String {
        return "/mobile/ios"
    }

    func isEnabled() -> Bool {
        guard let trackiSettings: [String:Any] = Utils.getSetting(identifier: MPXTracker.kTrackingSettings) else {
            return false
        }
        guard let trackingEnabled = trackiSettings[MPXTracker.kTrackingEnabled] as? Bool else {
            return false
        }
        return trackingEnabled
    }

    open class func setTrack(listener: MPTrackListener) {
        sharedInstance.trackListener = listener
    }

    open func getTrackListener() -> MPTrackListener? {
        return trackListener
    }

    open func startNewFlow() {
        flowService.startNewFlow()
    }

    open func startNewFlow(externalFlowId:String) {
        flowService.startNewFlow(externalFlowId: externalFlowId)
    }

    open func getFlowID() -> String {
        return flowService.getFlowId()
    }
}

// MARK: Public interfase.
extension MPXTracker {

    open func trackScreen(screenId: String, screenName: String, properties: [String: String] = [:]) {
        if let trackListenerInterfase = trackListener {
            trackListenerInterfase.trackScreen(screenName: screenName, extraParams: properties)
        }
        if !isEnabled() {
            return
        }
        setTrackingStrategy(screenID: screenId)
        let screenTrack = MPTScreenTrackInfo(screenName: screenName, screenId: screenId, properties: properties)
        trackingStrategy.trackScreen(screenTrack: screenTrack)
    }

    open func trackActionEvent(action: String, screenId: String, screenName: String, properties: [String: String] = [:]) {
        if !isEnabled() {
            return
        }
        let trackingStrategy = RealTimeStrategy() // TODO: Use other strategies
        let screenTrack = MPTActionEventInfo(action: action, screenName: screenName, screenId: screenId, properties: properties)
        self.trackingStrategy = trackingStrategy
        trackingStrategy.trackActionEvent(actionEvenTrack: screenTrack)
    }

    open func setTrackingStrategy(screenID: String) {
        let forcedScreens: [String] = [TrackingUtil.SCREEN_ID_PAYMENT_RESULT,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_APPROVED,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_PENDING,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_REJECTED,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_INSTRUCTIONS,
                                       TrackingUtil.SCREEN_ID_ERROR]
        if forcedScreens.contains(screenID) {
            trackingStrategy = ForceTrackStrategy()
        } else {
            trackingStrategy = BatchStrategy()
        }
    }
}

// MARK: Internal interfase.
extension MPXTracker {

    internal func generateJSONDefault() -> [String:Any] {
        let deviceJSON = MPTDevice().toJSON()
        let applicationJSON = MPTApplication(checkoutVersion: MPXTracker.sharedInstance.getSdkVersion(), platform: MPXTracker.sharedInstance.getPlatformType(), flowId: flowService.getFlowId(), environment: currentEnvironment).toJSON()
        let obj: [String:Any] = [
            "application": applicationJSON,
            "device": deviceJSON
        ]
        return obj
    }

    // TODO: Remove it is not used
    internal func generateJSONScreen(screenId: String, screenName: String, metadata: [String:Any]) -> [String:Any] {
        var obj = generateJSONDefault()
        let screenJSON = self.screenJSON(screenId: screenId, screenName: screenName, metadata:metadata)
        obj["events"] = [screenJSON]
        return obj
    }

    internal func generateJSONEvent(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        var obj = generateJSONDefault()
        let eventJSON = self.eventJSON(screenId: screenId, screenName: screenName, action: action, category: category, label: label, value: value)
        obj["events"] = [eventJSON]
        return obj
    }

    internal func eventJSON(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        let timestamp = Date().getCurrentMillis()
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "action",
            "screen_id": screenId,
            "screen_name": screenName,
            "action": action,
            "category": category,
            "label": label,
            "value": value
        ]
        return obj
    }

    // Todo: Remove, it is not used
    internal func screenJSON(screenId: String, screenName: String, metadata: [String:Any]) -> [String:Any] {
        let timestamp = Date().getCurrentMillis()
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "screenview",
            "screen_id": screenId,
            "screen_name": screenName,
            "metadata": metadata
        ]
        return obj
    }
}

