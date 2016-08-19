//
//  ViewController.swift
//  LocationTester
//
//  Created by Peter Mareš on 17/08/2016.
//  Copyright © 2016 Peter Mareš. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

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
    @IBOutlet weak var map: MKMapView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.locMgr = CLLocationManager()
        self.distance = loadDistanceTravelled()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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

        map.scrollEnabled = false
        map.zoomEnabled = true
        map.rotateEnabled = true
        map.showsUserLocation = true
        
        initMap()
        
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
        latitudeLabel.text = "\(String(format: "%.6f", loc.coordinate.latitude))"
        longitudeLabel.text = "\(String(format: "%.6f", loc.coordinate.longitude))"
        speedLabel.text = "\(loc.speed >= 0.0 ? loc.speed : 0.0) m/s"
        altitudeLabel.text = "\(String(format: "%.2f meters", loc.altitude))"
        distanceLabel.text = "\(String(format: "%.2f meters", distance))"
        
        updateMap(loc)
    }
    
    func initMap() {
        let center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        map.region = region
    }
    
    func updateMap(loc: CLLocation) {
        map.region.center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
    }
    
    // MARK: Actions
    @IBAction func resetButtonPressed(sender: UIButton) {
        self.distance = 0.0
        saveDistanceTravelled(self.distance)
        print("Reset button pressed")
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            if loc.speed >= 0.0 {
                print("1. \(distance)")
                if let lastLoc = lastLocation {
                    distance += loc.distanceFromLocation(lastLoc)
                }
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
        print("Authorisation status changed to \(status.rawValue)")
    }
}

