# AR In Retails:

Let's create a generic template how AR(Augmented Reality) and NLP(Natural Language Processing) can be applied to Retail market to leverage the maximum benefits to customer like Offers, finding items in your shopping list, creating the shopping list using NLP based system, getting offers from assistant, showing the navigation path in AR etc.

Main Components used here: 

(1). Google dialogflow: Fullfilled by our own back-end hosted in heroku with clearDB mySql database.

(2). iOS mobile app having AR. 

(3). Estimote beacons: To give the indoor positioning of the user inside the store.

(4). Google map: it helps to identify the user location whether he/she is inside the store or not.


# Architecture of the entire project:
  
<img width="500" alt="screen shot 2018-06-18 at 11 53 15 am" src="https://user-images.githubusercontent.com/10649284/41897746-c7e952c6-7945-11e8-917b-ac349c232997.png">

# Flow:

## Part 1: Store identification:

App will decide whether user is inside the store or not using google maps and user core location. 

(1). Based on user location, app send the user lat and lng  to back-end

(2). Back-end will do a reverse geo code to convert (lat, lng) to formatted address where you will get the zipCode.

(3). Get the stores information from ZipCode with their physical position (lat, lng)

(4). Send the information to the mobile app, app will decide whether user location belongs to any of the stores or not.

(5). If user is inside the store, it will open the store map else it will open the Walmart assistant

![googlemap](https://user-images.githubusercontent.com/10649284/41901064-a901db46-794d-11e8-9c7a-982fe41d1a40.png)

## Part 2: Store Map:

If user is inside the store, user will get the user location (blue dot) on store 2-D map. 

We are using <b>Estimote beacons</b> to identify the user location inside store.

User will get 2 options: (1). Assistant (2). AR view

![store-map-navigate](https://user-images.githubusercontent.com/10649284/41901066-a93b932c-794d-11e8-869f-1ec0129e48c7.PNG)

## Part 3: NLP (Natural language processing) based assistant: 

(1). We are using DialogFlow for assistant where user can get offers of the day at the very begining.

![assistant-1](https://user-images.githubusercontent.com/10649284/41901056-a7a01d44-794d-11e8-9aa3-eb0dd59427ef.PNG)

(2). User will add product to the shopping list with the help of assistant. Dialogflow send the information to our back-end which is hosted to heroku, it called the walmartlabs developer open api to fetch the products list.

![assistant-2-search](https://user-images.githubusercontent.com/10649284/41901057-a7dfada6-794d-11e8-9afa-930010196f5c.PNG)

 If user choose any of the product, it will be added to the shopping list.
 
![assistant-3-add](https://user-images.githubusercontent.com/10649284/41901059-a8191578-794d-11e8-8850-b10a9885c63c.PNG)
 
(3). User can ask to the assistant to show the shopping list:

![assistant-4-list](https://user-images.githubusercontent.com/10649284/41899226-8bb5ce02-7949-11e8-885a-cd7476f723da.PNG)


(3). User can remove the shopping list any time with the help of assistant.

![assistant-5-delete](https://user-images.githubusercontent.com/10649284/41901062-a88ccf40-794d-11e8-8c32-8d19833980a7.PNG)

(4). you can start shopping, the Augmented Reality view will help the user to navigate throught the products

(5). user can also get the offers based on his past history purchase list. We are using the mock data in server and recommending the user about product busket level offers.

![assistant-6-offer](https://user-images.githubusercontent.com/10649284/41901063-a8c2b6a0-794d-11e8-8749-905843f789df.png)

### Part 4: Open AR (Augmented Reality) view:

(1). User will get a path from his/her location to the shopping list products.

(2). The path will be created based on single-source shorest path to all the items.

(3). User can see the offers of other department also in AR while navigating through the path.

![ar-1](https://user-images.githubusercontent.com/10649284/41900768-0ce4130a-794d-11e8-84b5-4e231c0e5e9d.png)
![ar-2](https://user-images.githubusercontent.com/10649284/41900773-0f2ca79e-794d-11e8-9fbe-ee4ccef0a258.png)

(3). User will get a collection view of items in AR view. Once user will get the item, he/she can update the shopping list by tapping on that.

![ar-3](https://user-images.githubusercontent.com/10649284/41900986-85f39180-794d-11e8-8285-ef0a72062eb6.png)

(4). User will get notified through notification when he/she is close to a particular products department.

<img width="375" alt="screen shot 2018-06-26 at 2 22 50 pm" src="https://user-images.githubusercontent.com/10649284/41900509-8a7095ec-794c-11e8-9908-7e6f05d00da1.png">


# General Information about beacons: 

### Using iBeacons:

<b> Beacon: </b>
a low energy bluetooth device which transmit signal.

<b> iBeacon: </b>
iBeacon is the Apple provided framework to capture the beacon signal in iOS platform.

### Define a Beacon: 

    import CoreLocation
    
    class Item: NSObject, NSCoding {
    
    let name: String
    let icon: Int
    let uuid: UUID // 128 bit Int
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var beacon: CLBeacon?
    
    init(name: String, icon: Int, uuid: UUID, majorValue: Int, minorValue: Int) {
        self.name = name
        self.icon = icon
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue) // UInt32
        self.minorValue = CLBeaconMinorValue(minorValue) // UInt32
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: name)
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .far: return "far"
        case .immediate: return "immediate"
        case .near: return "near"
        case .unknown: return "unknown"
        }
    }
    
    func locationString() -> String {
        guard let beacon = beacon else { return "Location Unknown" }
        let proximity = nameForProximity(beacon.proximity)
        let accurancy = String(format: "%0.2f", beacon.accuracy)
        var location = "location \(proximity)"
        if beacon.proximity != .unknown {
            location += "approx. \(accurancy) m "
        }
        return location
    }
    }
    
A beacon has identifier, UUID, majorValue and minorValue. It emits signal. App will receive those signal through <b>CLLocationManagerDelegate</b>.

### Start Monitoring Beacons signal:

    func startMonitoringBeaconItems(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringBeaconItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }


### Listening Beacons signal:

    // MARK: CLLocationDelegate
    extension ItemsViewController: CLLocationManagerDelegate {
    
    // error handling
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print(error.localizedDescription)
      }
      func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
         print("Error while detectiong Region:\(region?.identifier ?? ""), with error: \(error.localizedDescription)")
       }
       func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
          print("Error while finding beacon region: \(region.identifier) with error:\(error.localizedDescription)")
       }
    
       // listening beacons
       func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
          print(beacons)
        }
    }
   

