//
//  LocationViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MapKit

import GoogleMaps
import GooglePlaces

class TractorViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, TerminalTableCellDelegate, GMSMapViewDelegate {

    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var mapView: MapView!
   // @IBOutlet weak var mapView: MKMapView!
   // @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl : UISegmentedControl!
    
    var showMap = false

    var tractorSearchInfo : TractorSearchInfo!

    var tractorArray: [TractorInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Tractor Search"
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addUnderlineForSelectedSegment()

        tractorSearchInfo = DataManager.sharedInstance.fetchFilterDefaultValues()
        DataManager.sharedInstance.tractorSearchInfo = self.tractorSearchInfo

        self.fetchTractorLocations()
        
        mapView.selectedRadius = Int((DataManager.sharedInstance.tractorSearchInfo?.radius)!)!
        mapView.initialSetup()
        mapView.mapFilterDelegate = self

//        tractorArray = DataManager.sharedInstance.tractorList
//        self.addTractorAnnotations()
//        tableView.reloadData()
        
        self.view.backgroundColor = UIColor.white

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.viewControllers[0].isKind(of: TractorViewController.self))!
        {
            self.setNavigationBarItem()
        }
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
            mapView.isHidden = true
            tableView.isHidden = false
            
            showMap = false
        case 1:
            mapView.isHidden = false
            tableView.isHidden = true
            
            showMap = true
        default:
            break;
        }
    }
    
    @IBAction func filterButtonAction()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorFilterViewController") as! TractorFilterViewController
        viewCtrl.searchCompletionHandler = {(searchInfo) in
            self.tractorSearchInfo = searchInfo
            self.fetchTractorLocations()
        }
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
        var mapLocationList: [TractorInfo] = []
        
        var searchLocation: CLLocation = CLLocation(latitude: tractorSearchInfo.latitude, longitude: tractorSearchInfo.longitude)
        for info in tractorArray
        {
            let dist = GMSGeometryDistance(CLLocationCoordinate2DMake(info.latitude,info.longitude),
                                           searchLocation.coordinate) / 1609
            if (Int(dist) <= Int(self.tractorSearchInfo.radius)!) {
                mapLocationList.append(info)
            }
           
        }
        
        mapView.setSelectedRadius(Int(self.tractorSearchInfo.radius)!)
        mapView.searchLocation = searchLocation
        mapView.addTractorList(mapLocationList)
        mapView.zoomMapToRadius()
        
    }
}

//MARK: - TableView delgate

extension TractorViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tractorArray.count == 0) ? 0 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return tractorArray.count;
        
        var numOfSections: Int = 0
        if tractorArray.count != 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = tractorArray.count
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : TerminalTableCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TerminalTableCell", for: indexPath) as! TerminalTableCell
        
        let info = tractorArray[indexPath.section]
        cell.showTractorInfo(info)
        
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderColor  =  UIColor.clear.cgColor
        cell.contentView.layer.borderWidth = 5.0
        cell.contentView.layer.shadowOpacity = 0.5
        cell.contentView.layer.shadowColor =  UIColor.lightGray.cgColor
        cell.contentView.layer.shadowRadius = 5.0
        cell.contentView.layer.shadowOffset = CGSize(width:5, height: 5)
        cell.contentView.layer.masksToBounds = true
        
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

extension TractorViewController: MapFilterDelegate {
    func mapFilter(sender: MapView){
        self.tractorSearchInfo.latitude = sender.searchLocation.coordinate.latitude
        self.tractorSearchInfo.longitude = sender.searchLocation.coordinate.longitude
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(sender.searchLocation.coordinate) { (response, error) in
            let address = response?.firstResult()
            self.tractorSearchInfo.city = (address?.locality)!
            self.tractorSearchInfo.state = (address?.administrativeArea)!
            self.tractorSearchInfo.zip = (address?.postalCode)!
        }
        
        self.tractorSearchInfo.radius = String(sender.selectedRadius)
        
        self.fetchTractorLocations()
//        self.addTractorAnnotations()
    }
}

