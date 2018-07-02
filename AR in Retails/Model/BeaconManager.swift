//
//  BeaconManager.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/16/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import UserNotifications
import EstimoteProximitySDK

struct BeaconConstants {
    static let appId = "explore-world-aox"
    static let appToken = "f97b822b4052ae9d44f1802f9dc5ce3b"
    static let locationName = "Walmart Store"
    static let storeOrientation: Double = 270 // with respect to true north
    static let storeWidth: CGFloat = 10
    static let storeHeight: CGFloat = 10
    
    // beacons
    struct Purple1 {
        static let identifier = "466aa0756095522195038c737d29e61f"
        static let position = CGPoint(x: 0, y: 10)
        static let attachmentValue = "purple1"
    }
    
    struct Purple2 {
        static let identifier = "9b9532806d66002812707710ac27fa2d"
        static let position = CGPoint(x: 0, y: 0)
        static let attachmentValue = "purple2"
    }
    
    struct Pink1 {
        static let identifier = "bc9acba5091010f1af1c2673386a8d1c"
        static let position = CGPoint(x: 10, y: 10)
        static let attachmentValue = "pink1"
    }
    
    struct Pink2 {
        static let identifier = "f8caf97dd768d9c2f981379e7e439a3d"
        static let position = CGPoint(x: 10, y: 0)
        static let attachmentValue = "pink2"
    }
    
    // not used now 
    struct Yellow1 {
        static let identifier = "b9e0a297628e933e4998b691968a5e08"
        static let position = CGPoint(x: 4.5, y: 5)
        static let attachmentValue = "yellow1"
    }
    
    struct Yellow2 {
        static let identifier = "7dcb5539b9bc3e8411202f0e2829c80c"
        static let position = CGPoint(x: 4.5, y: 0)
        static let attachmentValue = "yellow2"
    }
    
    
}

protocol UserPositionUpdateProtocol:class {
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation)
    func userDidEnterBeaconsRegion(attachmentValue: String)
}

class BeaconManager: NSObject {
    
    let locationManager = EILIndoorLocationManager()
    var location: EILLocation?
    
    let estimoteBeaconManager = ESTBeaconManager()
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    weak var delegate: UserPositionUpdateProtocol?
    var proximityObserver: EPXProximityObserver!
    
    
    override init() {
        super.init()
        
        // indoor location manager
        locationManager.delegate = self
        ESTConfig.setupAppID(BeaconConstants.appId, andAppToken: BeaconConstants.appToken)
        
        if let beaconLocation = beaconsSetup() {
            location = beaconLocation
            locationManager.startPositionUpdates(for: beaconLocation)
        }
        
        // estimote
        estimoteBeaconManager.delegate = self
        estimoteBeaconManager.requestAlwaysAuthorization()
        
        // local notification
        userNotificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        userNotificationCenter.requestAuthorization(options: options) { (isGranted, error) in
            if !isGranted {
                print("something wrong in local notification permission")
            }
        }
        
        setupLocalNotification()
        defineProximityZone()
    }
    
    private func beaconsSetup() -> EILLocation? {
        let locationBuilder = EILLocationBuilder()
        
        locationBuilder.setLocationName(BeaconConstants.locationName)
        let boundaryPoints: [EILPoint] = [
            EILPoint(x: Double(BeaconConstants.Purple2.position.x), y: Double(BeaconConstants.Purple2.position.y)),
            EILPoint(x: Double(BeaconConstants.Purple1.position.x), y: Double(BeaconConstants.Purple1.position.y)),
            //EILPoint(x: Double(BeaconConstants.Yellow1.position.x), y: Double(BeaconConstants.Yellow1.position.y)),
            EILPoint(x: Double(BeaconConstants.Pink1.position.x), y: Double(BeaconConstants.Pink1.position.y)),
            EILPoint(x: Double(BeaconConstants.Pink2.position.x), y: Double(BeaconConstants.Pink2.position.y))
           // EILPoint(x: Double(BeaconConstants.Yellow2.position.x), y: Double(BeaconConstants.Yellow2.position.y)),
        ]
        locationBuilder.setLocationBoundaryPoints(boundaryPoints)
        locationBuilder.setLocationOrientation(BeaconConstants.storeOrientation)
        
        // adding beacons to the builder
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Purple2.identifier, atBoundarySegmentIndex: 0, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Purple1.identifier, atBoundarySegmentIndex: 1, inDistance: 0, from: .leftSide)
       // locationBuilder.addBeacon(withIdentifier: BeaconConstants.Yellow1.identifier, atBoundarySegmentIndex: 2, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Pink1.identifier, atBoundarySegmentIndex: 2, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Pink2.identifier, atBoundarySegmentIndex: 3, inDistance: 0, from: .leftSide)
       // locationBuilder.addBeacon(withIdentifier: BeaconConstants.Yellow2.identifier, atBoundarySegmentIndex: 5, inDistance: 0, from: .leftSide)
        
        return locationBuilder.build()
    }

}

// MARK: Indoor positioning delegate

extension BeaconManager: EILIndoorLocationManagerDelegate {
    
    func indoorLocationManager(_ manager: EILIndoorLocationManager, didFailToUpdatePositionWithError error: Error) {
        print("ERROR: failed to update position \(error)")
    }
    
    func indoorLocationManager(_ manager: EILIndoorLocationManager, didUpdatePosition position: EILOrientedPoint, with positionAccuracy: EILPositionAccuracy, in location: EILLocation) {
        
        var accuracy: String!
        switch positionAccuracy {
        case .veryHigh: accuracy = "+/- 1.00m"
        case .high:     accuracy = "+/- 1.62m"
        case .medium:   accuracy = "+/- 2.62m"
        case .low:      accuracy = "+/- 4.24m"
        case .veryLow:  accuracy = "+/- ? :-("
        case .unknown:  accuracy = "unknown"
        }
        //print(accuracy)
        delegate?.getUserUpdate(position: position, accuracy: positionAccuracy, location: location)
    }
}

// MARK: Beacon regions delegates

extension BeaconManager: ESTBeaconManagerDelegate {
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print("you entered a new beacon region: \(region)")
    }
    
    private func setupNotification(attachmentValue: String) {
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        var desc = ""
        
        switch attachmentValue {
        case BeaconConstants.Purple1.attachmentValue:
            desc = "Buy 2kg apples and get 1kg extra\n Buy 3 dozens of banana and get 1 dozen free"
        case BeaconConstants.Purple2.attachmentValue:
            desc = "Shop more than 3,000 and get coupons of 500\n Off upto 50% on fbb products"
        case BeaconConstants.Pink1.attachmentValue:
            desc = "25% off on every pair of shoes\n 40% off on Nike brand. Only for today"
        case BeaconConstants.Pink2.attachmentValue:
            desc = "Use American Express card and get 10% off on IPod\n Exchange offers on IPhone 7 or above"
        default: break
        }
        
        content.body = desc
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = attachmentValue
        
        // Deliver the notification in one second.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "hello", content: content, trigger: trigger)
        
        userNotificationCenter.add(request) { (error : Error?) in
            if let theError = error {
                print("theError \(theError)")
            }
        }
    }
    
    func beaconManager(_ manager: Any, didChange status: CLAuthorizationStatus) {
        print("authorization status changed: \(status)")
    }
}

// MARK: Local Notification handling

extension BeaconManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // play sound and show alert to the user
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("perform some Dismiss action handler")
        case UNNotificationDefaultActionIdentifier:
            print("perform some default action handler here")
        default:
            print("default action handler of local notification")
        }
    }
}

// MARK: Proximity & notifications

extension BeaconManager {
    
    private func setupLocalNotification() {
        
        var allCategories = Set<UNNotificationCategory>()
        
        [BeaconConstants.Pink1.attachmentValue, BeaconConstants.Pink2.attachmentValue, BeaconConstants.Purple1.attachmentValue, BeaconConstants.Purple2.attachmentValue].forEach {
            let action = UNNotificationAction(identifier: $0, title: $0, options: [.destructive])
            let category = UNNotificationCategory(identifier: $0, actions: [action], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
            allCategories.insert(category)
        }
       userNotificationCenter.setNotificationCategories(allCategories)
    }
    
    
    func defineProximityZone() {
        
        let couldCredentials = EPXCloudCredentials(appID: BeaconConstants.appId, appToken: BeaconConstants.appToken)
        let configuration = EPXProximityObserverConfiguration()
        proximityObserver = EPXProximityObserver(credentials: couldCredentials, configuration: configuration, errorBlock: { (error) in
            print(error.localizedDescription)
        })
        
        // pink 1
        let pink1 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: BeaconConstants.Pink1.attachmentValue)
        pink1.onEnterAction = { [weak self] context in
            print("You entered into the Pink 1 Zone")
            self?.setupNotification(attachmentValue: BeaconConstants.Pink1.attachmentValue)
            self?.delegate?.userDidEnterBeaconsRegion(attachmentValue: BeaconConstants.Pink1.attachmentValue)
        }
        pink1.onExitAction = { _ in
            print("Bye Bye Pink 1 Zone")
        }
        
        // Pink 2
        let pink2 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: BeaconConstants.Pink2.attachmentValue)
        pink2.onEnterAction = { [weak self] context in
            print("You entered into the Pink 2 Zone")
            self?.setupNotification(attachmentValue: BeaconConstants.Pink2.attachmentValue)
            self?.delegate?.userDidEnterBeaconsRegion(attachmentValue: BeaconConstants.Pink2.attachmentValue)
        }
        pink2.onExitAction = { _ in
            print("Bye Bye Pink 2 Zone")
        }
        
        // purple 1
        let purple1 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: BeaconConstants.Purple1.attachmentValue)
        purple1.onEnterAction = { [weak self] context in
            print("You entered into the Purple 1 Zone")
            self?.setupNotification(attachmentValue: BeaconConstants.Purple1.attachmentValue)
            self?.delegate?.userDidEnterBeaconsRegion(attachmentValue: BeaconConstants.Purple1.attachmentValue)
        }
        purple1.onExitAction = { _ in
            print("Bye Bye Purple 1 Zone")
        }
        
        // Purple 2
        let purple2 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: BeaconConstants.Purple2.attachmentValue)
        purple2.onEnterAction = { [weak self] context in
            print("You entered into the Purple 2 Zone")
            self?.setupNotification(attachmentValue: BeaconConstants.Purple2.attachmentValue)
            self?.delegate?.userDidEnterBeaconsRegion(attachmentValue: BeaconConstants.Purple2.attachmentValue)
        }
        purple2.onExitAction = { _ in
            print("Bye Bye Purple 2 Zone")
        }
        
        // yellow 2
        let yellow2 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: "yellow2")
        yellow2.onEnterAction = { context in
            print("You entered into the Yellow 2 Zone")
        }
        yellow2.onExitAction = { _ in
            print("Bye Bye Yellow 2 Zone")
        }
        
        // yellow 1
        let yellow1 = EPXProximityZone(range: .near, attachmentKey: "color", attachmentValue: "yellow1")
        yellow1.onEnterAction = { context in
            print("You entered into the Yellow 2 Zone")
        }
        yellow1.onExitAction = { _ in
            print("Bye Bye Yellow 2 Zone")
        }
        
        proximityObserver.startObserving([pink2, purple2, yellow2])
    }
    
}
