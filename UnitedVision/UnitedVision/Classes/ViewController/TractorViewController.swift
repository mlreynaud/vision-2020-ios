//
//  LocationViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import MapKit

import GoogleMaps
import GooglePlaces

class TractorViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, TerminalTableCellDelegate, GMSMapViewDelegate,SideMenuLogOutDelegate {
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var mapView: MapView!

    @IBOutlet weak var segmentedControl : UISegmentedControl!
    
    var showMap = false

    var tractorSearchInfo : TractorSearchInfo!

    var tractorArray = [TractorInfo]()
    
    var searchBarBtn : UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tractor Search"
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addUnderlineForSelectedSegment()

        tractorSearchInfo = DataManager.sharedInstance.tractorSearchInfo ?? DataManager.sharedInstance.fetchFilterDefaultValues()!
        DataManager.sharedInstance.tractorSearchInfo = self.tractorSearchInfo

        self.fetchTractorLocations()
        
        mapView.selectedRadius = Int((DataManager.sharedInstance.tractorSearchInfo?.radius)!)!
        mapView.initialSetup(forType: .TractorType)
        mapView.mapFilterDelegate = self

//        tractorArray = DataManager.sharedInstance.tractorList
//        self.addTractorAnnotations()
//        tableView.reloadData()
        
        self.view.backgroundColor = UIColor.white
        addSearchBarButton()
        tableView.register(UINib(nibName: "TerminalTableCell", bundle: Bundle.main), forCellReuseIdentifier: "TerminalTableCell")
    }
    func addSearchBarButton() {
        searchBarBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TractorViewController.searchBarBtnPressed))
        searchBarBtn?.isEnabled = false
        searchBarBtn?.tintColor = .clear
        self.navigationItem.rightBarButtonItem = searchBarBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.topViewController?.isKind(of: TractorViewController.self))!
        {
            self.setNavigationBarItem()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK-

    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {
        segmentedControl.updateUnderLineWidth(newWidth: size.width)
        mapView.parentVCOrientationChanged()
    }
    
    func sideMenuLogOutPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
        
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        sender.changeUnderlinePosition()

        switch sender.selectedSegmentIndex {
        case 0:
            mapView.isHidden = true
            tableView.isHidden = false
            searchBarBtn?.isEnabled = false
            searchBarBtn?.tintColor = .clear
            showMap = false
        case 1:
            mapView.isHidden = false
            tableView.isHidden = true
            searchBarBtn?.isEnabled = true
            searchBarBtn?.tintColor = nil
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
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
        
        let searchLocation: CLLocation = CLLocation(latitude: tractorSearchInfo.latitude, longitude: tractorSearchInfo.longitude)
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
    @objc func searchBarBtnPressed() {
        self.mapView.presentAutoCompleteController()
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
        var cell : TerminalTableCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TerminalTableCell", for: indexPath) as? TerminalTableCell
        
        let info = tractorArray[indexPath.section]
        cell?.showTractorInfo(info)
        cell?.delegate = self
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK- TerminalTableCell delegate methods
    
    func callAtIndex (_ cell: TerminalTableCell)
    {
        DataManager.sharedInstance.addNewCallLog(cell.tractorId!, userId:DataManager.sharedInstance.userTypeStr)
//        UIUtils.callPhoneNumber()
    }
    
    func showMapAtIndex (_ cell: TerminalTableCell)
    {
        segmentedControl.selectedSegmentIndex = 1
        segmentControlValueChanged(segmentedControl)
        let indexPath = tableView.indexPath(for: cell)
        mapView.mapBtnTapped(forTractorAt: indexPath!)
    }
}

extension TractorViewController: MapFilterDelegate {
    func mapFilter(sender: MapView){
        if let searchLocation = sender.searchLocation{
            self.tractorSearchInfo.latitude = searchLocation.coordinate.latitude
            self.tractorSearchInfo.longitude = searchLocation.coordinate.longitude
            
            let geocoder: GMSGeocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(searchLocation.coordinate) { (response, error) in
                let address = response?.firstResult()
                self.tractorSearchInfo.city = (address?.locality)!
                self.tractorSearchInfo.state = (address?.administrativeArea)!
                self.tractorSearchInfo.zip = (address?.postalCode)!
            }
            
            self.tractorSearchInfo.radius = String(sender.selectedRadius)
            self.fetchTractorLocations()
        }
    }
}

