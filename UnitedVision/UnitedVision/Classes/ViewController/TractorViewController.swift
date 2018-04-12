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

class TractorViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, TractorTableCellDelegate, GMSMapViewDelegate,SideMenuLogOutDelegate {
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var mapView: MapView!

    @IBOutlet weak var segmentedControl : UISegmentedControl!
    
    @IBOutlet weak var filterBtnView: UIView!
    
    var showMap = false

    var tractorSearchInfo : TractorSearchInfo!

    var tractorArray = [TractorInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(withTitle: "TRACTOR SEARCH", Frame: nil)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addUnderlineForSelectedSegment()

        tractorSearchInfo = DataManager.sharedInstance.tractorSearchInfo ?? DataManager.sharedInstance.fetchFilterDefaultValues()!
        DataManager.sharedInstance.tractorSearchInfo = self.tractorSearchInfo

        self.fetchTractorLocations()
        
        mapView.selectedRadius = Int((DataManager.sharedInstance.tractorSearchInfo?.radius)!)!
        mapView.initialSetup(forType: .TractorType)
        mapView.mapFilterDelegate = self

        self.view.backgroundColor = UIColor.white
        addSearchBarButton()
        addSortBarBtn()
        tableView.register(UINib(nibName: "TractorTableCell", bundle: Bundle.main), forCellReuseIdentifier: "TractorTableCell")
        tableView.separatorStyle = .none
    }
    
    func addSearchBarButton() {
        let searchBarBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TractorViewController.searchBarBtnPressed))
        self.navigationItem.rightBarButtonItem = searchBarBtn
    }
    
    func addSortBarBtn() {
        let sortBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        sortBtn.setImage(UIImage(named: "ic_sort_blue"), for: .normal)
        sortBtn.addTarget(self, action:  #selector(sortBtnPressed), for: .touchUpInside)
        let searchBarBtn = UIBarButtonItem(customView: sortBtn)
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
            showMap = false
            addSortBarBtn()
        case 1:
            mapView.isHidden = false
            tableView.isHidden = true
            showMap = true
            addSearchBarButton()
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
        annotation.coordinate = coordinate
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
                self.mapView.addSearchCentreMarker()
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
    @objc func sortBtnPressed() {
        let tractorSortVC = TractorSortViewController.initiateTractorSortVC()
        tractorSortVC.sortCompletionHandler = { (selectedSortType) in
            if selectedSortType != nil {
                self.performListSortingFor(SortType: selectedSortType!)
            }
        }
        tractorSortVC.modalPresentationStyle = .overCurrentContext
        tractorSortVC.modalTransitionStyle = .crossDissolve
        self.present(tractorSortVC, animated: true, completion: nil)
    }
    
    func performListSortingFor(SortType sortType:TractorSortType){
        if sortType == .EDestinationCity {
           tractorArray = tractorArray.sorted(by: { ($0.destinationCity ?? "")! <  ($1.destinationCity ?? "")! })
        }
        else if sortType == .EDistance {
            tractorArray = tractorArray.sorted(by: { ($0.distanceFromShipper)! <  ($1.distanceFromShipper)! })
        }
        else if sortType == .ETractorType {
            tractorArray = tractorArray.sorted(by: { ($0.tractorType ?? "")! <  ($1.tractorType ?? "")! })
        }
        else if sortType == .ETerminal {
            tractorArray = tractorArray.sorted(by: { ($0.terminal ?? "")! <  ($1.terminal ?? "")! })
        }
        else if sortType == .EStatus {
            tractorArray = tractorArray.sorted(by: { ($0.status ?? "")! <  ($1.status ?? "")! })
        }
        tableView.reloadData()
    }

}

//MARK: - TableView delgate

extension TractorViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows: Int = 0
        if tractorArray.count != 0{
            tableView.separatorStyle = .singleLine
            numOfRows = tractorArray.count
            tableView.backgroundView = nil
        }
        else{
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (tractorArray.count == 0) ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : TractorTableCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TractorTableCell", for: indexPath) as? TractorTableCell
        
        let info = tractorArray[indexPath.row]
        cell?.delegate = self
        cell?.setTractorInfo(tractorInfo: info)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK- TractorTableCell delegate methods
    
    func showMapAtIndex (_ cell: TractorTableCell)
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
                self.tractorSearchInfo.city = (address?.locality) ?? ""
                self.tractorSearchInfo.state = (address?.administrativeArea) ?? ""
                self.tractorSearchInfo.zip = (address?.postalCode) ?? ""
            }
            
            self.tractorSearchInfo.radius = String(sender.selectedRadius)
            self.fetchTractorLocations()
        }
    }
}

