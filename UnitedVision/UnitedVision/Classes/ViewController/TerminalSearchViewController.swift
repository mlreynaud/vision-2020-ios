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

class TerminalSearchViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, GMSMapViewDelegate {
    
    
    @IBOutlet weak var radiusTextField : UITextField!
    
    @IBOutlet var mapView: MapView!
    
//    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
//    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var searchLocation: CLLocation?
    
    var selectedRadius =  50
    
    var radiusList : [String] = []
    
    var locationArray: [LocationInfo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        radiusList = DataManager.sharedInstance.getRadiusList()
        self.title = "Terminal Search"
        
        mapView.initialSetup()
        searchLocation = mapView.getCurrentLocation()
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
        DataManager.sharedInstance.requestToFetchTractorLocations(completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()
            
            self.locationArray = tractorList! //DataManager.sharedInstance.tractorList
            self.mapLocations()
            
            //            self.addAnnotations()
            
            //            self.mapView.moveMapToCurrentLocation()
            //
            //            let currentLocation = self.mapView.getCurrentLocation()
            //            self.mapView.addRadiusCircle(location: currentLocation)
            
        })
    }
    
    func mapLocations() {
        var mapLocationList: [LocationInfo] = []
        for location in locationArray {
            let dist = GMSGeometryDistance(CLLocationCoordinate2DMake(location.latitude,-location.longitude),
                                           CLLocationCoordinate2DMake((searchLocation?.coordinate.latitude)!,
                                                                      (searchLocation?.coordinate.longitude)!)) / 1609
            if (Int(dist) <= selectedRadius) {
                mapLocationList.append(location)
            }
        }
        
        mapView.addLocationList(mapLocationList)
        mapView.zoomMapToRadius(selectedRadius)
    }
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated:true, completion: nil)
    }
    
}

extension TerminalSearchViewController : UITextFieldDelegate
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TerminalSearchViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(TerminalSearchViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        radiusTextField.inputView = pickerView
        radiusTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        
        radiusTextField.text = String("Radius: \(selectedRadius) mi")
        radiusTextField.resignFirstResponder()
        
        DataManager.sharedInstance.radius = selectedRadius
        
        //        let currentLocation = mapView.getCurrentLocation()
        //        mapView.addRadiusCircle(location: currentLocation)
        //        self.view.endEditing(true)
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

extension TerminalSearchViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        dismiss(animated: true, completion: nil)
        searchLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        DispatchQueue.main.async { () -> Void in
            self.mapView.setSearchLocation(self.searchLocation!)
            //            self.mapView.moveMaptoLocation(location: self.searchLocation!)
            self.mapLocations()
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

