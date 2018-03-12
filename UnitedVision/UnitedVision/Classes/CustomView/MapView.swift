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

protocol MapFilterDelegate: class {
    func mapFilter(sender: MapView)
}

class MapView: UIView, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate {
        
        
    @IBOutlet var map: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var autocompleteTableView: UITableView!
        
        var searchLocation: CLLocation!
        var selectedRadius: Int = 50
    
    var radiusList : [String] = []
    
    let nibName = "MapView"
    var view : UIView!
    
    
    
    weak var mapFilterDelegate: MapFilterDelegate?
    
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
        map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        map.delegate = self
        
        searchLocation = self.getCurrentLocation()
        
        searchBar.delegate = self
        
        radiusList = DataManager.sharedInstance.getRadiusList()

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
    
    func searchBarShouldBeginEditing(_ searchBar:UISearchBar) -> Bool {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let currentController = self.getCurrentViewController()
        currentController?.present(autocompleteController, animated:true, completion: nil)
        return false;
    }
    
    func getCurrentViewController() -> UIViewController? {
        var responder: UIResponder? = view
        repeat {
            responder = responder?.next
            if let vc = responder as? UIViewController {
                return vc
            }
        } while responder != nil
        
        return nil
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
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
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
        zoomLevel = map.camera.zoom
    }
}


extension MapView : UITextFieldDelegate, UIPickerViewDataSource
{
    func createPickerView()
    {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.darkGray //UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(MapView.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MapView.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        radiusTextField.inputView = pickerView
        radiusTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        
        radiusTextField.text = String("Radius: \(selectedRadius) mi")
        radiusTextField.resignFirstResponder()
        
        DataManager.sharedInstance.radius = selectedRadius
        self.mapFilterDelegate?.mapFilter(sender: self)
    }
    
    @objc func cancelClick() {
        radiusTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.createPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRadius =  Int(radiusList[row])!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return radiusList[row]
    }
}


extension MapView: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        searchLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        DispatchQueue.main.async { () -> Void in
           
            //            self.mapView.moveMaptoLocation(location: self.searchLocation!)
            self.mapFilterDelegate?.mapFilter(sender: self)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}




