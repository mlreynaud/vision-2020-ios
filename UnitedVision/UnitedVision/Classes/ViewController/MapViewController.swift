//
//  MapViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationArray: [TractorInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Terminal Search"
        
//        let userLocation = DataManager.sharedInstance.userLocation!
//        let region = MKCoordinateRegionMakeWithDistance(userLocation, 5000, 5000)
//        mapView.setRegion(region, animated: true)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = userLocation
//        annotation.title = "Current Location"
//
//        mapView.addAnnotation(annotation)
        
        self.addAnnotations()
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
    
    func addAnnotations(){
        
        var annotationList = [MKPointAnnotation]()
        locationArray = DataManager.sharedInstance.tractorList
        
        for info in locationArray
        {
            let annotation = self.createAnnotation(info: info as TractorInfo)
            annotationList.append(annotation)
        }
        
        mapView.addAnnotations(annotationList)
        mapView.showAnnotations(annotationList, animated: true);
        
    }
    
    func createAnnotation(info:TractorInfo) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude)
        annotation.title =  "Tractor ID - " + (info.tractorId)!
        annotation.subtitle = (info.originCity)! + "-" + (info.destinationCity)!
        return annotation

    }
    
    // MARK- Map delegate methods
    
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
