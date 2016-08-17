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

    var locMgr: CLLocationManager
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        self.locMgr = CLLocationManager()
        super.init(coder: aDecoder)
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
        locMgr.requestWhenInUseAuthorization()

        print("Location Services Enabled: \(CLLocationManager.locationServicesEnabled())")
        print("Heading available: \(CLLocationManager.headingAvailable())")
        
        locMgr.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations received: \(locations.count) points")
        for loc in locations {
            latitudeLabel.text = String(loc.coordinate.latitude)
            longitudeLabel.text = String(loc.coordinate.longitude)
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

