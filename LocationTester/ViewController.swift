//
//  ViewController.swift
//  LocationTester
//
//  Created by Peter Mareš on 17/08/2016.
//  Copyright © 2016 Peter Mareš. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let distanceKey = "Distance"
    let defaults = NSUserDefaults.standardUserDefaults()
    var locMgr = CLLocationManager()
    var distance: CLLocationDistance = 0.0
    var lastLocation: CLLocation?
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.locMgr = CLLocationManager()
        self.distance = loadDistanceTravelled()
        print(distance)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("viewDidLoad()")

        // intiailise the location manager
        switch CLLocationManager.authorizationStatus() {
        case    .Denied:
            print("Location Services denied!")
            fallthrough
        case    .Restricted:
            print("Location Services not enabled!")
        default:
            print("Location Services enabled")
            break
        }

        locMgr.delegate = self
        locMgr.requestAlwaysAuthorization()

        print("Location Services Enabled: \(CLLocationManager.locationServicesEnabled())")
        print("Heading available: \(CLLocationManager.headingAvailable())")
        
        locMgr.desiredAccuracy = kCLLocationAccuracyBest
        locMgr.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDistanceTravelled() -> CLLocationDistance {
        distance = defaults.doubleForKey(distanceKey)
        return distance
    }
    
    func saveDistanceTravelled(d: CLLocationDistance) {
        defaults.setValue(d, forKey: distanceKey)
    }
    
    func updateDisplay(loc: CLLocation) {
        latitudeLabel.text = "Latitude: \(loc.coordinate.latitude)"
        longitudeLabel.text = "Longitude: \(loc.coordinate.longitude)"
        speedLabel.text = "Speed: \(loc.speed >= 0.0 ? loc.speed : 0.0) m/s"
        altitudeLabel.text = "Altitude: \(loc.altitude)"
        distanceLabel.text = "Distance travelled: \(String(format: "%.2f meters", distance))"
    }
    
    // MARK: Actions
    @IBAction func resetButtonPressed(sender: UIButton) {
        self.distance = 0.0
        saveDistanceTravelled(self.distance)
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            if loc.speed >= 0.0 {
                print("1. \(distance)")
                if let lastLoc = lastLocation {
                    print("Updating distance")
                    distance += loc.distanceFromLocation(lastLoc)
                }
                print("2. \(distance)")
                print("last location: \(lastLocation)")
                self.lastLocation = loc;
            }
            
            updateDisplay(loc)
            saveDistanceTravelled(distance)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location failed with error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Authorisation status changed to \(status)")
        print(status.rawValue)
    }
}

