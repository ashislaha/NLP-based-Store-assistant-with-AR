# AR In Retails:

Let's create a simple template how AR can be applied to Retail market to leverage the maximum benefits through AR 
like Offers, items associated with each other and finding them.

# architecuture of the entire project:
  
<img width="500" alt="screen shot 2018-06-18 at 11 53 15 am" src="https://user-images.githubusercontent.com/10649284/41897746-c7e952c6-7945-11e8-917b-ac349c232997.png">

# Flow:

## Part 1: Store identification:

App will decide whether user is inside the store or not using google maps and user core location. 

(1). Based on user location, app send the user lat and lng  to back-end

(2). Back-end will do a reverse geo code to convert (lat, lng) to formatted address where you will get the zipCode.

(3). Get the stores information from ZipCode with their physical position (lat, lng)

(4). Send the information to the mobile app, app will decide whether user location belongs to any of the stores or not.

(5). If user is inside the store, it will open the store map else it will open the Walmart assistant

![googlemap](https://user-images.githubusercontent.com/10649284/41900149-a6e5441c-794b-11e8-9977-69f647c8f174.png)

## Part 2: Store Map:

If user is inside the store, user will get the user location (blue dot) on store 2-D map. 

We are using <b>Estimote beacons</b> to identify the user location inside store.

User will get 2 options: (1). Assistant (2). AR view

![store-map-navigate](https://user-images.githubusercontent.com/10649284/41899228-8cf5d9c4-7949-11e8-9b88-8cb9b13edb7a.PNG)

## Part 3: NLP (Natural language processing) based assistant: 

(1). We are using DialogFlow for assistant where user can get offers of the day at the very begining.

![assistant-1](https://user-images.githubusercontent.com/10649284/41899222-8a332d7c-7949-11e8-9c65-8c67f34c046c.PNG)

(2). User will add product to the shopping list with the help of assistant. Dialogflow send the information to our back-end which is hosted to heroku, it called the walmartlabs developer open api to fetch the products list.

![assistant-2-search](https://user-images.githubusercontent.com/10649284/41899224-8a92f482-7949-11e8-890c-287d27519a60.PNG)

 If user choose any of the product, it will be added to the shopping list.
 
 ![assistant-3-add](https://user-images.githubusercontent.com/10649284/41899225-8af82802-7949-11e8-83fc-5c2b4c55f8b7.PNG)
 
(3). User can ask to the assistant to show the shopping list:

![assistant-4-list](https://user-images.githubusercontent.com/10649284/41899226-8bb5ce02-7949-11e8-885a-cd7476f723da.PNG)


(3). User can remove the shopping list any time with the help of assistant.

![assistant-5-delete](https://user-images.githubusercontent.com/10649284/41899227-8c9fd45c-7949-11e8-9f7c-0344f0d72c5c.PNG)

(4). you can start shopping, the Augmented Reality view will help the user to navigate throught the products

(5). user can also get the offers based on his past history purchase list. We are using the mock data in server and recommending the user about product busket level offers.

![assistant-6-offer](https://user-images.githubusercontent.com/10649284/41900184-bd17e8ca-794b-11e8-9926-642efce81225.png)

### Part 4: Open AR (Augmented Reality) view:

(1). User will get a path from his/her location to the shopping list products.

(2). The path will be created based on single-source shorest path to all the items.

(3). User can see the offers of other department also in AR while navigating through the path.

![ar-1](https://user-images.githubusercontent.com/10649284/41900768-0ce4130a-794d-11e8-84b5-4e231c0e5e9d.png)
![ar-2](https://user-images.githubusercontent.com/10649284/41900773-0f2ca79e-794d-11e8-9fbe-ee4ccef0a258.png)

(3). User will get a collection view of items in AR view. Once user will get the item, he/she can update the shopping list by tapping on that.

![ar-3](https://user-images.githubusercontent.com/10649284/41900180-ba416c8e-794b-11e8-81f3-5d9a5f1ca1da.png)

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
   

