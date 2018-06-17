//
//  BeaconManager.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/16/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import UserNotifications

struct BeaconConstants {
    static let appId = "explore-world-aox"
    static let appToken = "f97b822b4052ae9d44f1802f9dc5ce3b"
    static let locationName = "Walmart Store"
    static let storeOrientation: Double = 270 // with respect to true north
    static let storeWidth: CGFloat = 8
    static let storeHeight: CGFloat = 8
    
    // beacons
    struct Purple1 {
        static let identifier = "466aa0756095522195038c737d29e61f"
        static let position = CGPoint(x: 0, y: 0)
    }
    
    struct Purple2 {
        static let identifier = "9b9532806d66002812707710ac27fa2d"
        static let position = CGPoint(x: 0, y: 8)
    }
    
    struct Pink1 {
        static let identifier = "bc9acba5091010f1af1c2673386a8d1c"
        static let position = CGPoint(x: 8, y: 0)
    }
    
    struct Pink2 {
        static let identifier = "f8caf97dd768d9c2f981379e7e439a3d"
        static let position = CGPoint(x: 8, y: 8)
    }
    
    struct Yellow1 {
        static let identifier = "b9e0a297628e933e4998b691968a5e08"
        static let position = CGPoint(x: 0, y: 4)
    }
    
    struct Yellow2 {
        static let identifier = "7dcb5539b9bc3e8411202f0e2829c80c"
        static let position = CGPoint(x: 8, y: 4)
    }
    
    
}

protocol UserPositionUpdateProtocol:class {
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation)
}

class BeaconManager: NSObject {
    
    let locationManager = EILIndoorLocationManager()
    var location: EILLocation?
    
    let estimoteBeaconManager = ESTBeaconManager()
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    weak var delegate: UserPositionUpdateProtocol?
    
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
    }
    
    private func beaconsSetup() -> EILLocation? {
        let locationBuilder = EILLocationBuilder()
        
        locationBuilder.setLocationName(BeaconConstants.locationName)
        let boundaryPoints: [EILPoint] = [
            EILPoint(x: Double(BeaconConstants.Purple1.position.x), y: Double(BeaconConstants.Purple1.position.y)),
            EILPoint(x: Double(BeaconConstants.Yellow1.position.x), y: Double(BeaconConstants.Yellow1.position.y)),
            EILPoint(x: Double(BeaconConstants.Purple2.position.x), y: Double(BeaconConstants.Purple2.position.y)),
            EILPoint(x: Double(BeaconConstants.Pink2.position.x), y: Double(BeaconConstants.Pink2.position.y)),
            EILPoint(x: Double(BeaconConstants.Yellow2.position.x), y: Double(BeaconConstants.Yellow2.position.y)),
            EILPoint(x: Double(BeaconConstants.Pink1.position.x), y: Double(BeaconConstants.Pink1.position.y))
        ]
        locationBuilder.setLocationBoundaryPoints(boundaryPoints)
        locationBuilder.setLocationOrientation(BeaconConstants.storeOrientation)
        
        // adding beacons to the builder
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Purple1.identifier, atBoundarySegmentIndex: 0, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Yellow1.identifier, atBoundarySegmentIndex: 1, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Purple2.identifier, atBoundarySegmentIndex: 2, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Pink2.identifier, atBoundarySegmentIndex: 3, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Yellow2.identifier, atBoundarySegmentIndex: 4, inDistance: 0, from: .leftSide)
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Pink1.identifier, atBoundarySegmentIndex: 5, inDistance: 0, from: .leftSide)
        
        return locationBuilder.build()
    }
    
    private func setupLocalNotification() {
        let grocery = UNNotificationAction(identifier: "groceries", title: "Groceries", options: [.destructive])
        let category = UNNotificationCategory(identifier: "groceries", actions: [grocery], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
        userNotificationCenter.setNotificationCategories([category])
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
        
        // you can send a notification if you want
        setupNotification()
    }
    
    private func setupNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "This is a new message from Groceries"
        content.sound = UNNotificationSound.default()
        
        //make sure to assign the correct category identifier
        content.categoryIdentifier = "groceries"
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
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
