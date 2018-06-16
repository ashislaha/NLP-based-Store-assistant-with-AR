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
    
    // beacons
    struct Purple1 {
        static let identifier = "466aa0756095522195038c737d29e61f"
        static let position = CGPoint(x: 0, y: 0)
    }
    
}

class BeaconManager: NSObject {
    
    let locationManager = EILIndoorLocationManager()
    let estimoteBeaconManager = ESTBeaconManager()
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        
        // indoor location manager
        locationManager.delegate = self
        ESTConfig.setupAppID(BeaconConstants.appId, andAppToken: BeaconConstants.appToken)
        buildLocation()
        
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
    
    func buildLocation() {
        let locationBuilder = EILLocationBuilder()
        
        // define boundary 
        let boundaryPoints: [EILPoint] = [EILPoint(x: 0, y: 0), EILPoint(x: 4.5, y: 0), EILPoint(x: 4.5, y: 4.5), EILPoint(x: 0, y: 4.5)]
        locationBuilder.setLocationBoundaryPoints(boundaryPoints)
        locationBuilder.setLocationOrientation(23)
        
        // add beacons
        locationBuilder.addBeacon(withIdentifier: BeaconConstants.Purple1.identifier, atBoundarySegmentIndex: 0, inDistance: 2, from: .leftSide)
        
    }
    
    private func setupLocalNotification() {
        let grocery = UNNotificationAction(identifier: "groceries", title: "Groceries", options: [.destructive])
        let category = UNNotificationCategory(identifier: "groceries", actions: [grocery], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
        userNotificationCenter.setNotificationCategories([category])
    }
    
    
}

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
        print(String(format: "x: %5.2f, y: %5.2f, orientation: %3.0f, accuracy: %@",
                     position.x, position.y, position.orientation, accuracy))
    }
}

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
