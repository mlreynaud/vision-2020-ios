//
//  MapViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar : UISearchBar!

    var locationArray: [LocationInfo] = []
    var tractorArray: [TractorInfo] = []

    let tractorSearchInfo = TractorSearchInfo()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Terminal Search"
        
        self.fetchTractorLocations()
        
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
    
    func fetchTractorLocations()
    {
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToFetchTractorLocations(completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()

            self.locationArray = tractorList! //DataManager.sharedInstance.tractorList
            self.addAnnotations()

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
        self.addAnnotationList(annotationList)
        
    }
    
    func addTractorAnnotations(){
        
        var annotationList = [MKPointAnnotation]()
        
        for info in tractorArray
        {
            let annotation = self.createAnnotation(coordinate: CLLocationCoordinate2DMake(info.latitude, info.longitude))
            
            annotation.title =  "Tractor ID - \(info.tractorId!)"
            annotation.subtitle = "\(info.originCity!) - \(info.destinationCity!)"
            
            annotationList.append(annotation)
        }
        
        self.addAnnotationList(annotationList)
       
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
    
    
   
}

// MARK: - Map delegate methods

extension MapViewController
{
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
    
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    //    {
    //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalDetailViewController") as! TerminalDetailViewController
    //        self.navigationController?.pushViewController(viewCtrl, animated: true)
    //    }

}

// MARK: - SearchBar delegate

extension MapViewController
{
    func searchBarBecomeFirstResponder ()
    {
        self.searchBar.becomeFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        let text = searchText.trimmingCharacters(in: CharacterSet.whitespaces)
//
//        NSObject.cancelPreviousPerformRequests(withTarget: self)
//
//        guard (text.count != 0) else{
//
//            searchBar.text = ""
//
//            print("No Search String");
//            return
//        }
//
////        self.perform(#selector(MapViewController.searchProduct(searchText:loadMore:)), with:searchBar.text, afterDelay: 0.5)
//    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        AppPrefData.sharedInstance.homeSearchText = searchBar.text
//        AppPrefData.sharedInstance.saveAllData()
        let text = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard text?.count != 0 else {
            searchBar.text = ""
            print("No Search String");
            return
        }
        
        self.searchTractor()
        
    }
    
    func searchTractor()
    {
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToSearchTractor(tractorSearchInfo, completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()
            
            self.tractorArray = tractorList! //DataManager.sharedInstance.tractorList
            self.addTractorAnnotations()
            
        })
    }
}
