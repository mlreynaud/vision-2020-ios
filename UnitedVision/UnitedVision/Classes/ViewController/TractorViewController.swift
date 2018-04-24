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

enum TractorSortType : Int {
    case EDestinationCity = 0
    case EDistance
    case ETractorType
    case ETerminal
    case EStatus
}

extension TractorSortType{
    public var description: String {
        switch self {
        case .EDestinationCity:
            return "Destination City"
        case .EDistance:
            return "Distance"
        case .ETractorType:
            return "Tractor Type"
        case .ETerminal:
            return "Terminal"
        case .EStatus:
            return "Status"
        }
    }
}

extension TractorSortType {
    static var array: [String] {
        var arr: [String] = []
        switch TractorSortType.EDestinationCity {
        case .EDestinationCity: arr.append(TractorSortType.EDestinationCity.description); fallthrough
        case .EDistance: arr.append(TractorSortType.EDistance.description); fallthrough
        case .ETractorType: arr.append(TractorSortType.ETractorType.description); fallthrough
        case .ETerminal: arr.append(TractorSortType.ETerminal.description); fallthrough
        case .EStatus: arr.append(TractorSortType.EStatus.description);
        }
        return arr
    }
}

let kSortBy = "Sort By"
let kCellPadding:CGFloat = 1

class TractorViewController: BaseViewController, UISearchBarDelegate, MKMapViewDelegate, TractorCollectionGridCellDelegate, GMSMapViewDelegate,SideMenuLogOutDelegate {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    @IBOutlet weak var mapView: MapView!

    @IBOutlet weak var segmentedControl : UISegmentedControl!
    
    @IBOutlet weak var bottomFilterBtnView: UIView!
    @IBOutlet weak var topFilterBtnView: UIView!
    
    @IBOutlet weak var bottomFilterBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topFilterBtnViewWidth: NSLayoutConstraint!

    var showMap = false

    var tractorSearchInfo : TractorSearchInfo!

    var tractorArray = [TractorInfo]()
    
    var collectionViewCellWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(withTitle: "TRACTOR SEARCH", Frame: nil)

        segmentedControl.removeBorder()
        segmentedControl.selectedSegmentIndex = 0

        tractorSearchInfo = DataManager.sharedInstance.tractorSearchInfo ?? DataManager.sharedInstance.fetchFilterDefaultValues()!
        DataManager.sharedInstance.tractorSearchInfo = self.tractorSearchInfo

        self.fetchTractorLocations()
        
        mapView.selectedRadius = Int((DataManager.sharedInstance.tractorSearchInfo?.radius)!)!
        mapView.initialSetup(forType: .TractorType)
        mapView.mapFilterDelegate = self

        self.view.backgroundColor = UIColor.white
        addSearchBarButton()
        addSortBarBtn()
        collectionView.register(UINib(nibName: "TractorCollectionGridCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TractorCollectionGridCell")

        setupCollectionView(screenSize: view.frame.size)
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
        repositionFilterBtn(size: view.frame.size)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControl.addUnderlineForSelectedSegment()
    }

    func repositionFilterBtn(size: CGSize){
        if UIDevice.current.orientation.isLandscape{
            bottomFilterBtnViewHeight.constant = 0
            topFilterBtnViewWidth.constant = size.width/2
        }
        else{
            bottomFilterBtnViewHeight.constant = 45
            topFilterBtnViewWidth.constant = 0
        }
    }
    
    //MARK-

    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {
        mapView.parentVCOrientationChanged()
        
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.segmentedControl.updateUnderLineWidth()
            self.setupCollectionView(screenSize: size)
            self.collectionView.reloadData()
        }
        repositionFilterBtn(size: size)
    }
    
    func sideMenuLogOutPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
        
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.isHidden = true
            collectionView.isHidden = false
            showMap = false
            addSortBarBtn()
        case 1:
            mapView.isHidden = false
            collectionView.isHidden = true
            showMap = true
            addSearchBarButton()
        default:
            break;
        }
    }
    
    @IBAction func filterButtonAction(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorFilterViewController") as! TractorFilterViewController
        viewCtrl.searchCompletionHandler = {(searchInfo) in
            self.tractorSearchInfo = searchInfo
            self.fetchTractorLocations()
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    func createAnnotation(coordinate:CLLocationCoordinate2D) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    func fetchTractorLocations(){
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.requestToSearchTractor(tractorSearchInfo, completionHandler: {( status, tractorList) in
            
            LoadingView.shared.hideOverlayView()
            
            if (status)
            {
                self.tractorArray = (tractorList)! //DataManager.sharedInstance.tractorList
                self.addTractorAnnotations()
                self.mapView.addSearchCentreMarker()
                self.collectionView.reloadData()
            }
        })
    }
    
    func addTractorAnnotations(){
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
        let sortPopOver = PopOverViewController.initiatePopOverVC()
        sortPopOver.dataList = TractorSortType.array
        sortPopOver.titleText = kSortBy
        sortPopOver.isCancelEnabled = false
        sortPopOver.popOverCompletionHandler = { (selectedOption) in
            if selectedOption != nil{
                self.performListSortingFor(SortType: TractorSortType(rawValue:selectedOption!)!)
            }
        }
        sortPopOver.modalPresentationStyle = .overCurrentContext
        sortPopOver.modalTransitionStyle = .crossDissolve
        self.present(sortPopOver, animated: true, completion: nil)
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
        collectionView.reloadData()
    }
}

//MARK: - collectionView delgate

extension TractorViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func setupCollectionView(screenSize: CGSize){

        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
            collectionViewCellWidth = screenSize.width/2 - kCellPadding
        }
        else {
            collectionViewCellWidth = screenSize.width
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (tractorArray.count == 0) ? 0 : 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfItems: Int = 0
        if tractorArray.count != 0{
            numOfItems = tractorArray.count
            collectionView.backgroundView = nil
        }
        else{
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            collectionView.backgroundView  = noDataLabel
        }
        return numOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TractorCollectionGridCell", for: indexPath) as? TractorCollectionGridCell

        let info = tractorArray[indexPath.row]
        cell?.delegate = self
        cell?.setTractorInfo(tractorInfo: info)

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellWidth, height: 110)
    }
    
//MARK- TractorCollectionViewCell delegate methods

    func showMapAtIndex (_ cell: TractorCollectionGridCell){
        segmentedControl.selectedSegmentIndex = 1
        segmentControlValueChanged(segmentedControl)
        let indexPath = collectionView.indexPath(for: cell)
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

