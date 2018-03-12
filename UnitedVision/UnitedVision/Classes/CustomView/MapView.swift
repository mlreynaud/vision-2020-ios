//
//  MapView.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps
import GooglePlaces

class MapView: UIView, GMSMapViewDelegate, CLLocationManagerDelegate {
        
        
    @IBOutlet var map: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var autocompleteTableView: UITableView!
        
        var searchLocation: CLLocation!
        var radius: Int = 50
    
    let nibName = "MapView"
    var view : UIView!
    
        
        var locationManager = CLLocationManager()
        var currentLocation: CLLocation?
        var placesClient: GMSPlacesClient!
    
    
    var kDefaultZoom: Float = 8.0
    
        var zoomLevel: Float = 15.0
        
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func initialSetup()
    {
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        map.settings.compassButton = true
//        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        map.delegate = self
        
        searchLocation = self.getCurrentLocation()

//        locationManager = CLLocationManager()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//        locationManager.distanceFilter = 50
//        locationManager.startUpdatingLocation()
//        locationManager.delegate = self
        
        zoomLevel = kDefaultZoom
    }
    
    func loadViewFromNib() ->UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
        
        
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation = locations.last
//        currentLocation = userLocation
//        if searchLocation == nil {
//            searchLocation = userLocation!
//            moveMaptoLocation(location: currentLocation!)
//        }
//        locationManager.stopUpdatingLocation()
//        
//    }
    
    
    @IBAction func zoomOutButtonClicked(sender: UIButton)
    {
        self.map.animate(toZoom: self.map.camera.zoom + 0.5)
    }
    
    @IBAction func zoomInButtonClicked(sender: UIButton)
    {
        self.map.animate(toZoom: self.map.camera.zoom - 0.5)
    }

    func setSearchLocation(_ location: CLLocation) {
        self.searchLocation = location
    }
}


extension MapView
{
    func moveMapToCurrentLocation()
    {
        let currentLocation = self.getCurrentLocation()
        self.moveMaptoLocation(location: currentLocation)
        
    }
    
    func getCurrentLocation() -> CLLocation
    {
        let coordinate = DataManager.sharedInstance.userLocation
        let currentLocation = CLLocation(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
        return currentLocation
    }

    
}

extension MapView
{
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKCircle {
                let circle = MKCircleRenderer(overlay: overlay)
                circle.strokeColor = UIColor.darkGray
                circle.fillColor = UIColor(white: 0, alpha: 0.2)
                circle.lineWidth = 1
                return circle
            } else {
                return MKPolylineRenderer()
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
        {
            if annotation is MKUserLocation {
                return nil
            }
            let reuseID = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
            if(pinView == nil) {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                // pinView?.tintColor = UIColor.red
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
            }
            return pinView
        }
    
        
        func addRadiusCircle()
        {
            let meterRadius = DataManager.sharedInstance.radius * 1609
            let circle: GMSCircle = GMSCircle(position: (searchLocation?.coordinate)!,
                                              radius: CLLocationDistance(meterRadius))
            circle.map = map
        }
    
    func addLocationList(_ locationList: [LocationInfo])
    {
        map.clear()
        for location in locationList {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: -location.longitude)
            //            marker.snippet = location.detail
            marker.map = map
        }
        addRadiusCircle()
    }
    
    func addTractorList(_ tractorList: [TractorInfo])
    {
        map.clear()
        for location in tractorList {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: -location.longitude)
            //            marker.snippet = location.detail
            marker.map = map
        }
        addRadiusCircle()
    }
    
    func moveMaptoLocation(location: CLLocation){
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: self.zoomLevel)
        self.map.animate(to: camera)
    }

    
    func zoomMapToRadius(_ radius: Int) {
        let center: CLLocationCoordinate2D = searchLocation!.coordinate
        let meterRadius = CLLocationDistance(radius*1609)
        let n: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 0)
        let e: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 90)
        let s: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 180)
        let w: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 270)
        
        var bounds: GMSCoordinateBounds = GMSCoordinateBounds.init()
        bounds = bounds.includingCoordinate(n).includingCoordinate(e).includingCoordinate(s).includingCoordinate(w)
        map.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    
        //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
        //    {
        //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalDetailViewController") as! TerminalDetailViewController
        //        self.navigationController?.pushViewController(viewCtrl, animated: true)
        //    }
        
}
