//
//  MapViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit

class TerminalSearchViewController: BaseViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var autocompleteTableView : UITableView!

    @IBOutlet weak var radiusTextField : UITextField!
    
    var selectedRadius =  50
    
    var radiusList : [String] = []

    var matchingItems: [MKMapItem] = []

    var locationArray: [LocationInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var value = 25
        for i in 0...20
        {
            radiusList.append(String(value))
            value += 25
        }
        
        self.title = "Terminal Search"
        UIUtils.transparentSearchBarBackgrund(searchBar)
        
        autocompleteTableView.estimatedRowHeight = 100
        autocompleteTableView.rowHeight = UITableViewAutomaticDimension
        
        self.fetchTerminalLocations()
        
        self.autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrentLocationTableCell")
        
//        let userLocation = DataManager.sharedInstance.userLocation!
//        let region = MKCoordinateRegionMakeWithDistance(userLocation, 5000, 5000)
//        mapView.setRegion(region, animated: true)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = userLocation
//        annotation.title = "Current Location"
//
//        mapView.addAnnotation(annotation)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
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
            self.addAnnotations()
            
            self.moveMapToCurrentLocation()

        })
    }
    
    func addAnnotations(){
        
        var annotationList = [MKPointAnnotation]()
        
        for info in locationArray
        {
            let annotation = self.createAnnotation(coordinate: CLLocationCoordinate2DMake(info.latitude, info.longitude))
            
            annotation.title =  "Tractor ID - 1"
            annotation.subtitle = info.detail
            
            annotationList.append(annotation)
        }
        
        mapView.addAnnotations(annotationList)
        mapView.showAnnotations(annotationList, animated: true);
//        self.addAnnotationList(annotationList)
        
    }
    
    func addAnnotationList(_ annotationList: [MKPointAnnotation])
    {
        if mapView.annotations.count != 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        mapView.addAnnotations(annotationList)
        mapView.showAnnotations(annotationList, animated: true);
    }
    
//    func removeAllAnnotations()
//    {
//        let annotations = mapView.annotations.filter {
//            $0 !== self.mapView.userLocation
//        }
//        mapView.removeAnnotations(annotations)
//    }
    
    func createAnnotation(coordinate:CLLocationCoordinate2D) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate //CLLocationCoordinate2DMake(info.latitude, info.longitude)

//        annotation.subtitle = (info.originCity)! + "-" + (info.destinationCity)!
        return annotation

    }
    
    func moveMaptoLocation(location: CLLocation){
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let span = MKCoordinateSpanMake(2.0, 2.0)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
   
}

// MARK: - Map delegate methods

extension TerminalSearchViewController
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 2
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
    
    func addRadiusCircle(location: CLLocation)
    {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let circle = MKCircle(center: location.coordinate, radius: CLLocationDistance(selectedRadius))
        self.mapView.add(circle)
    }
    
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    //    {
    //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalDetailViewController") as! TerminalDetailViewController
    //        self.navigationController?.pushViewController(viewCtrl, animated: true)
    //    }

}

// MARK: - SearchBar delegate

extension TerminalSearchViewController
{
    func searchBarBecomeFirstResponder ()
    {
        self.searchBar.becomeFirstResponder()
        let text = (self.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces))!
        if (text.count > 0){
            self.searchAutocompleteEntriesWithSubstring(text)
        }

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: CharacterSet.whitespaces)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard (text.count != 0) else{
            searchBar.text = ""
            print("No Search String");
            return
        }

        self.perform(#selector(searchAutocompleteEntriesWithSubstring) , with:searchBar.text, afterDelay: 0.5)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        AppPrefData.sharedInstance.homeSearchText = searchBar.text
//        AppPrefData.sharedInstance.saveAllData()
        let searchBarText = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard searchBarText?.count != 0 else {
            searchBar.text = ""
            print("No Search String");
            return
        }
        
       //        self.searchTractor()
        
    }
    
    @objc func searchAutocompleteEntriesWithSubstring(_ searchText: String)
    {
        // Request to fetch autocomplete text
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            
            print(self.matchingItems)
            self.autocompleteTableView.reloadData()
        }
        
        self.autocompleteTableView.isHidden = false
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
}

extension TerminalSearchViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchingItems.count + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell : AutocompleteTableCell!
        
        if (indexPath.row == 0){
            
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CurrentLocationTableCell", for: indexPath) 
            cell.textLabel?.text = "Current Location";
            cell.textLabel?.textColor = .blue
            return cell;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteTableCell", for: indexPath) as! AutocompleteTableCell
        
        let info: MKMapItem = self.matchingItems[indexPath.row - 1]
        let placemark = info.placemark
        if info.isCurrentLocation == false
        {
            cell.titleLabel.text = placemark.name!
            cell.subtitleLabel.text = self.parseAddress(selectedItem: placemark)
        }
        else
        {
            cell.titleLabel.text = info.name!
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.searchBar.resignFirstResponder()
        tableView.isHidden = true
        
        if (indexPath.row == 0)
        {
//            let coordinate = DataManager.sharedInstance.userLocation
//            let currentLocation = CLLocation(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
//            self.moveMaptoLocation(location: currentLocation)
            
            self.moveMapToCurrentLocation()
            return
        }
        
        let info: MKMapItem = self.matchingItems[indexPath.row - 1]
        let placemark = info.placemark
        searchBar.text = placemark.name
        
        self.moveMaptoLocation(location: placemark.location!)
    }
    
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
        
        let currentLocation = self.getCurrentLocation()
        self.addRadiusCircle(location: currentLocation)
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
