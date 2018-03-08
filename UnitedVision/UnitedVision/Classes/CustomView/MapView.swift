//
//  MapView.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import Foundation
import MapKit

class MapView: UIView, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var map : MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var autocompleteTableView: UITableView!

    var matchingItems: [MKMapItem] = []
    
    let nibName = "MapView"
    var view : UIView!
    
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
        UIUtils.transparentSearchBarBackgrund(self.searchBar)

        
        // register Nibs
        self.autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrentLocationTableCell")
        
        self.autocompleteTableView.register(UINib(nibName: "AutocompleteTableCell", bundle: Bundle.main), forCellReuseIdentifier: "AutocompleteTableCell")

        autocompleteTableView.estimatedRowHeight = 100
        autocompleteTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadViewFromNib() ->UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    @IBAction func zoomOutButtonClicked(sender: UIButton)
    {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*2, longitudeDelta: map.region.span.longitudeDelta*2)
        let region = MKCoordinateRegion(center: map.region.center, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    @IBAction func zoomInButtonClicked(sender: UIButton)
    {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta/2, longitudeDelta: map.region.span.longitudeDelta/2)
        let region = MKCoordinateRegion(center: map.region.center, span: span)
        
        map.setRegion(region, animated: true)
    }

}

extension MapView
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
        request.region = map.region
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

extension MapView
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
    
    // MARK-
        
        func addRadiusCircle(location: CLLocation)
        {
            let overlays = map.overlays
            map.removeOverlays(overlays)
            
            let radiusInMile = DataManager.sharedInstance.radius
            let radiusInMeter = CLLocationDistance(radiusInMile) * 1609.34
            let circle = MKCircle(center: location.coordinate, radius: CLLocationDistance(radiusInMeter))
            self.map.add(circle)
        }
    
    func addAnnotationList(_ annotationList: [MKPointAnnotation])
    {
        if map.annotations.count != 0 {
            map.removeAnnotations(map.annotations)
        }
        
        map.addAnnotations(annotationList)
       map.showAnnotations(annotationList, animated: true);
    }
    
//        func removeAllAnnotations()
//        {
//            let annotations = mapView.annotations.filter {
//                $0 !== self.mapView.userLocation
//            }
//            map.removeAnnotations(annotations)
//        }
    
    func createAnnotation(coordinate:CLLocationCoordinate2D) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate //CLLocationCoordinate2DMake(info.latitude, info.longitude)
        
        //        annotation.subtitle = (info.originCity)! + "-" + (info.destinationCity)!
        return annotation
        
    }
    
    func moveMaptoLocation(location: CLLocation){
        
//        let span = MKCoordinateSpanMake(0.05, 0.05)
        let span = MKCoordinateSpanMake(2.0, 2.0)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        map.setRegion(region, animated: true)
    }

        
        //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
        //    {
        //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalDetailViewController") as! TerminalDetailViewController
        //        self.navigationController?.pushViewController(viewCtrl, animated: true)
        //    }
        
}
