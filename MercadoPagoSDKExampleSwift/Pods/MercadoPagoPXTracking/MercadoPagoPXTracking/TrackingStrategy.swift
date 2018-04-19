//
//  File.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 7/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

protocol TrackingStrategy {
    func trackScreen(screenTrack: MPTScreenTrackInfo)
}

class RealTimeStrategy: TrackingStrategy { // V1
    func trackScreen(screenTrack: MPTScreenTrackInfo) {
        self.send(trackList: [screenTrack])
    }

    func trackActionEvent(actionEvenTrack: MPTActionEventInfo) {
        self.send(trackList: [actionEvenTrack])
    }
    
    private func send(trackList: Array<MPTrackInfo>) {
        var jsonBody = MPXTracker.sharedInstance.generateJSONDefault()
        var arrayEvents = Array<[String:Any]>()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents

        let body = JSONHandler.jsonCoding(jsonBody)
        let params = "public_key=\(MPXTracker.sharedInstance.public_key)"
        let header : [String: String] = [PXTrackingURLConfigs.headerEventTracking: PXTrackingSettings.eventsTrackingVersion]

        TrackingServices.request(url: PXTrackingURLConfigs.TRACKING_URL, params: params, body: body, method: "POST", headers: header, success: { (result) -> Void in
        }) { (error) -> Void in
        }
    }
}

class BatchStrategy: TrackingStrategy { // V2

    func trackScreen(screenTrack: MPTScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        attemptSendTrackInfo()
    }

    func canSendTrack() -> Bool {
        let status = MPXReach().connectionStatus()
        if status.description == "Offline" {
            return false
        }
        return status.description == "Online (WiFi)" || UIApplication.shared.applicationState == UIApplicationState.background
    }

    func attemptSendTrackInfo() {
        if canSendTrack() {
            let array = TrackStorageManager.getBatchScreenTracks(force: false)
            guard let batch = array else {
                return
            }
            send(trackList: batch)
        }
    }
    private func send(trackList: Array<MPTScreenTrackInfo>) {
        var jsonBody = MPXTracker.sharedInstance.generateJSONDefault()
        var arrayEvents = Array<[String:Any]>()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        let params = "public_key=\(MPXTracker.sharedInstance.public_key)"
        let header : [String: String] = [PXTrackingURLConfigs.headerEventTracking: PXTrackingSettings.eventsTrackingVersion]

        TrackingServices.request(url: PXTrackingURLConfigs.TRACKING_URL, params: params, body: body, method: "POST", headers: header, success: { (result) -> Void in
        }) { (error) -> Void in
            TrackStorageManager.persist(screenTrackInfoArray: trackList) // Vuelve a guardar los tracks que no se pudieron trackear
        }
    }

}

class ForceTrackStrategy: TrackingStrategy { // V2

    func trackScreen(screenTrack: MPTScreenTrackInfo) {
        TrackStorageManager.persist(screenTrackInfo: screenTrack)
        attemptSendTrackInfo(force:true)
    }

    func canSendTrack() -> Bool {
        let status = MPXReach().connectionStatus()
        if status.description == "Offline" {
            return false
        }
        return true
    }

    func attemptSendTrackInfo(force: Bool = false) {
        if canSendTrack() {
            let array = TrackStorageManager.getBatchScreenTracks(force: true)
            guard let batch = array else {
                return
            }
            send(trackList: batch)
            attemptSendTrackInfo(force: force)
        }
    }
    private func send(trackList: [MPTScreenTrackInfo]) {
        var jsonBody = MPXTracker.sharedInstance.generateJSONDefault()
        var arrayEvents = [[String: Any]]()
        for elementToTrack in trackList {
            arrayEvents.append(elementToTrack.toJSON())
        }
        jsonBody["events"] = arrayEvents
        let body = JSONHandler.jsonCoding(jsonBody)
        let params = "public_key=\(MPXTracker.sharedInstance.public_key)"
        let header : [String: String] = [PXTrackingURLConfigs.headerEventTracking: PXTrackingSettings.eventsTrackingVersion]

        TrackingServices.request(url: PXTrackingURLConfigs.TRACKING_URL, params: params, body: body, method: "POST", headers: header, success: { (result) -> Void in
        }) { (error) -> Void in
            TrackStorageManager.persist(screenTrackInfoArray: trackList) // Vuelve a guardar los tracks que no se pudieron trackear
        }
    }

}
