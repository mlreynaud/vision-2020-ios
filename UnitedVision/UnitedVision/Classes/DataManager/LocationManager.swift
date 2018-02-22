//
//  LocationManager.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = LocationManager()
    
    var locationManager: CLLocationManager!

    fileprivate override init() {}
    
    func initializeLocationManager()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    func startUpdateLocation()
    {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationUpdate()
    {
        locationManager.stopUpdatingLocation()
    }
    
    func checkLocationAuthorizationStatus() -> Bool{
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
           return true
        } else {
           return false //locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last as! CLLocation
        let currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        DataManager.sharedInstance.userLocation = currentLocation
        
        locationManager.stopUpdatingLocation()

//        latitude.text = String(format: "%.4f",
//                               latestLocation.coordinate.latitude)
//        longitude.text = String(format: "%.4f",
//                                latestLocation.coordinate.longitude)
//        horizontalAccuracy.text = String(format: "%.4f",
//                                         latestLocation.horizontalAccuracy)
//        altitude.text = String(format: "%.4f",
//                               latestLocation.altitude)
//        verticalAccuracy.text = String(format: "%.4f",
//                                       latestLocation.verticalAccuracy)
        
//        if startLocation == nil {
//            startLocation = latestLocation
//        }
//
//        let distanceBetween: CLLocationDistance =
//            latestLocation.distance(from: startLocation)
//
//        distance.text = String(format: "%.2f", distanceBetween)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error)
    {
        print(error)
    }
}
