//
//  LocationViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit


class TractorViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, TerminalTableCellDelegate {

    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var mapBackgroundView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl : UISegmentedControl!

    var showMap = false

    let tractorSearchInfo = TractorSearchInfo()

    var tractorArray: [TractorInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Tractor Search"
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addUnderlineForSelectedSegment()

        UIUtils.transparentSearchBarBackgrund(searchBar)
//        self.fetchTractorLocations()
        
        tractorArray = DataManager.sharedInstance.tractorList
        self.addTractorAnnotations()
        tableView.reloadData()

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
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        sender.changeUnderlinePosition()

        switch sender.selectedSegmentIndex {
        case 0:
            mapBackgroundView.isHidden = true
            tableView.isHidden = false
            
            showMap = false
        case 1:
            mapBackgroundView.isHidden = false
            tableView.isHidden = true
            
            showMap = true
        default:
            break;
        }
    }
    
    @IBAction func filterButtonAction()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    func createAnnotation(coordinate:CLLocationCoordinate2D) -> MKPointAnnotation
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate //CLLocationCoordinate2DMake(info.latitude, info.longitude)
        
        //        annotation.subtitle = (info.originCity)! + "-" + (info.destinationCity)!
        return annotation
    }
    
    func fetchTractorLocations()
    {
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToSearchTractor(tractorSearchInfo, completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()
            
            if (status)
            {
                self.tractorArray = (tractorList)! //DataManager.sharedInstance.tractorList
                self.addTractorAnnotations()
                self.tableView.reloadData()
            }
            
        })
    }
        
    
    func addTractorAnnotations()
    {
        var annotationList = [MKPointAnnotation]()
        
        for info in tractorArray
        {
            let annotation = self.createAnnotation(coordinate: CLLocationCoordinate2DMake(info.latitude, info.longitude))
            
            annotation.title =  "Tractor ID - \(info.tractorId!)"
            annotation.subtitle = "\(info.originCity!) - \(info.destinationCity!)"
            
            annotationList.append(annotation)
           
        }
        mapView.addAnnotations(annotationList)
        mapView.showAnnotations(annotationList, animated: true);
        
    }
}

//MARK: - TableView delgate

extension TractorViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tractorArray.count;
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : TerminalTableCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TerminalTableCell", for: indexPath) as! TerminalTableCell
        
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let info = tractorArray[indexPath.section]
        cell.showTractorInfo(info)
        
        cell.layer.shadowOffset = CGSize(width:1,height:0)//CGSizeMake(1, 0)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 5;
        cell.layer.shadowOpacity = 0.25;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! TerminalSearchViewController
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    //MARK- TerminalTableCell delegate methods
    
    func callAtIndex (_ indexpath: IndexPath)
    {
        
    }
    
    func showMapAtIndex (_ indexpath: IndexPath)
    {
        
    }
    
}

extension TractorViewController
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

extension TractorViewController
{
    func searchBarBecomeFirstResponder ()
    {
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
}

