//
//  MapViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class TerminalSearchViewController: BaseViewController, GMSMapViewDelegate {
    
    
    @IBOutlet weak var radiusTextField : UITextField!
    
    @IBOutlet var mapView: MapView!
    
//    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
//    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    
    
    var locationArray: [LocationInfo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Terminal Search"
        
        mapView.initialSetup()
        mapView.searchLocation = mapView.getCurrentLocation()
        mapView.mapFilterDelegate = self
        self.fetchTerminalLocations()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            print("Locaiton status not determined")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.navigationController?.viewControllers[0].isKind(of: TerminalSearchViewController.self) )!
        {
            self.setNavigationBarItem()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK-
    
    func fetchTerminalLocations()
    {
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToFetchTerminalLocations(completionHandler: {( status, terminalList) in
            
            LoadingView.shared.hideOverlayView()
            
            self.locationArray = terminalList! //DataManager.sharedInstance.tractorList
            self.mapLocations()
            
        })
    }
    
    func mapLocations() {
        var mapLocationList: [LocationInfo] = []
        for location in locationArray {
            let dist = GMSGeometryDistance(CLLocationCoordinate2DMake(location.latitude,-location.longitude),
                                           CLLocationCoordinate2DMake((mapView.searchLocation?.coordinate.latitude)!,
                                                                      (mapView.searchLocation?.coordinate.longitude)!)) / 1609
            if (Int(dist) <= mapView.selectedRadius) {
                mapLocationList.append(location)
            }
        }
        
        mapView.addLocationList(mapLocationList)
        mapView.zoomMapToRadius()
    }

}


extension TerminalSearchViewController: MapFilterDelegate {
    func mapFilter(sender: MapView) {
        self.mapLocations()
    }
}

