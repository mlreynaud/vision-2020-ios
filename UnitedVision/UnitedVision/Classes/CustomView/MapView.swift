//
//  MapView.swift
//  UnitedVision
//
//  Created by Agilink on 05/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

protocol MapFilterDelegate: class {
    func mapFilter(sender: MapView)
}

class GoogleMapMarker : GMSMarker{
    
    var locationInfoArr = [LocationInfo]()
    var tractorInfo : TractorInfo?
    
    let selectedMarkerImg : UIImage = GMSMarker.markerImage(with: .green)
    let unSelectedMarkerImg : UIImage = GMSMarker.markerImage(with: nil)
    
    let headQuarterSelectedImg = UIImageView(image: UIImage(named: "uv_shield_50_green")!)
    let headQuarterUnSelectedImg = UIImageView(image: UIImage(named: "uv_shield_50")!)
    
    var isCorporateOffice = false
    
    override init() {
        super.init()
        headQuarterSelectedImg.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        headQuarterUnSelectedImg.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    func setMarker(){
        if tractorInfo != nil{
            icon = unSelectedMarkerImg
        }
        else if locationInfoArr.count != 0 {
            for locationInfo in locationInfoArr{
                if (locationInfo.corporateOffice ?? "") == "Y"{
                    isCorporateOffice = true
                }
            }
            if isCorporateOffice{
                iconView = headQuarterUnSelectedImg
            }
            else {
                icon = unSelectedMarkerImg
            }
        }
    }
    
    func toggleMarkerSelection(){
        if tractorInfo != nil{
            icon = icon == unSelectedMarkerImg ?  selectedMarkerImg : unSelectedMarkerImg
        }
        else if locationInfoArr.count != 0{
            for locationInfo in locationInfoArr{
                if locationInfo.corporateOffice ?? "" == "Y"{
                    isCorporateOffice = true
                }
            }
            if isCorporateOffice{
                iconView = iconView == headQuarterSelectedImg ? headQuarterUnSelectedImg : headQuarterSelectedImg
            }
            else{
                icon = icon == unSelectedMarkerImg ?  selectedMarkerImg : unSelectedMarkerImg
            }
        }
    }
    func colorMarkerGreen(){
        if tractorInfo != nil{
            icon = selectedMarkerImg
        }
        else if locationInfoArr.count != 0{
            for locationInfo in locationInfoArr{
                if (locationInfo.corporateOffice ?? "") == "Y"{
                    isCorporateOffice = true
                }
            }
            if isCorporateOffice{
                iconView = headQuarterSelectedImg
            }
            else {
                icon = selectedMarkerImg
            }
        }
    }
}

let kTractorGridCellHeight : CGFloat = 110
let kTractorMapCellHeight : CGFloat = 90
let kTerminalMapCellHeight : CGFloat = 95

class MapView: UIView, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var detailCollectionViewContainer: UIView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var detailCollectionViewheight: NSLayoutConstraint!
    var cellIdentifier: String?
    var detailCollectionViewCellHeight:CGFloat = 0
    
    @IBOutlet var map: GMSMapView!
    var markers = [GoogleMapMarker]()
    var detailViewArr = [GoogleMapMarker]()
    
    
    @IBOutlet var myLocationBtnOutlet: UIButton!
    var myLocationBtn : UIButton?
    
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var radiusLbl: UILabel!
    
    var detailViewTractorInfo : TractorInfo?
    var detailViewLocationInfo : LocationInfo?
    
    var searchLocation: CLLocation?
    var selectedRadius: Int = 50
    
    var radiusList : [String] = []
    var mapViewType: MapViewType?
    
    let nibName = "MapView"
    var view : UIView!
    
    weak var mapFilterDelegate: MapFilterDelegate?
    
    var locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient!
    
    var kDefaultZoom: Float = 8.0
    
    var zoomLevel: Float = 15.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }
    deinit{
        removeObserver(self, forKeyPath: #keyPath(map.selectedMarker))
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() ->UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func initialSetup(forType mapViewType : MapViewType) {
        self.mapViewType = mapViewType
        updateGoogleMapSettings()
        setupUpMyLocationBtn()
        updateSettingVariables()
        zoomMapToRadius()
        setupCollectionView()
        addObserver(self, forKeyPath: #keyPath(map.selectedMarker), options: [.old, .new], context: nil)
    }
    
    func updateGoogleMapSettings(){
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        map.settings.compassButton = true
        map.delegate = self
    }
    
    func updateSettingVariables(){
        searchLocation = self.getCurrentLocation()
        radiusList = DataManager.sharedInstance.getRadiusList()
        radiusLbl.attributedText = String("Radius \(selectedRadius) mi").createAttributedString(subString: "\(selectedRadius) mi", subStringColor: .blue)
        zoomLevel = kDefaultZoom
    }
   
    func setupUpMyLocationBtn(){
        myLocationBtnOutlet.imageView?.contentMode = .scaleAspectFit
        fetchMyLocationBtn()
    }
    
    @IBAction func myLocationBtnPressed(){
        myLocationBtn?.sendActions(for: .touchUpInside)
    }
    
    func fetchMyLocationBtn(){
        for view in map.subviews {
            if  type(of: view).description()  == "GMSUISettingsPaddingView"{
                for subView in view.subviews {
                    if  type(of: subView).description()  == "GMSUISettingsView"{
                        for settingSubView in subView.subviews{
                            if  type(of: settingSubView).description()  == "GMSx_QTMButton"{
                                myLocationBtn = settingSubView as? UIButton
                                myLocationBtn?.isHidden = true
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parentVCOrientationChanged(){
        if radiusTextField.isEditing{
            radiusTextField.resignFirstResponder()
        }
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.setupCollectionIdentifierAndHeight()
            self.setupDetailCollectionViewHeight()
        }
    }
    
    @IBAction func zoomOutButtonClicked(sender: UIButton)
    {
        self.map.animate(toZoom: self.map.camera.zoom + 0.5)
    }
    
    @IBAction func zoomInButtonClicked(sender: UIButton)
    {
        self.map.animate(toZoom: self.map.camera.zoom - 0.5)
    }
    
    func setSearchLocation(_ location: CLLocation) {
        self.searchLocation = location
    }
    
    func setSelectedRadius(_ radius: Int) {
        self.selectedRadius = radius
        radiusLbl.attributedText = String("Radius \(selectedRadius) mi").createAttributedString(subString: "\(selectedRadius) mi", subStringColor: .blue)
    }
    
    func presentAutoCompleteController(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let currentController = self.getCurrentViewController()
        currentController?.present(autocompleteController, animated:true, completion: nil)
    }
    
    func getCurrentViewController() -> UIViewController? {
        var responder: UIResponder? = view
        repeat {
            responder = responder?.next
            if let vc = responder as? UIViewController {
                return vc
            }
        } while responder != nil
        
        return nil
    }
}


extension MapView
{
    func moveMapToCurrentLocation()
    {
        if let currentLocation = self.getCurrentLocation(){
            self.moveMaptoLocation(location: currentLocation)
        }
    }
    
    func getCurrentLocation() -> CLLocation?
    {
        var currentLocation : CLLocation? = nil
        if LocationManager.sharedInstance.checkLocationAuthorizationStatus() {
            if let coordinate = DataManager.sharedInstance.userLocation {
                currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
        else{
            UIUtils.showAlert(withTitle: kAppTitle, message: "Please Check your GPS permissions", inContainer: getCurrentViewController()!)
        }
        return currentLocation
    }
}

extension MapView
{
    
    func addRadiusCircle()
    {
        if searchLocation != nil{
            let meterRadius = selectedRadius * 1609
            let circle: GMSCircle = GMSCircle(position: (searchLocation?.coordinate)!,
                                              radius: CLLocationDistance(meterRadius))
            
            circle.strokeColor = UIColor(hexString:"884286f4")
            circle.strokeWidth = 4.0
            circle.fillColor = UIColor(hexString: "224286f4")
            circle.map = map
        }
    }
    func addSearchCentreMarker() {
        if let searchCentrePosition = searchLocation{
            let marker = GoogleMapMarker()
            marker.opacity = 0.7
            marker.position = CLLocationCoordinate2D(latitude: searchCentrePosition.coordinate.latitude, longitude: searchCentrePosition.coordinate.longitude)
            marker.iconView = UIImageView(image: UIImage(named: "search_loc_marker")?.withRenderingMode(.alwaysTemplate))
            marker.map = map
            markers.append(marker)
        }
    }
    
    func addLocationList(_ locationList: [LocationInfo])
    {
        markers.removeAll()
        map.clear()
        for location in locationList {
            if !checkIfMarkerWithLocationExists(locationInfo: location){
                let marker = GoogleMapMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                marker.locationInfoArr.append(location)
                markers.append(marker)
            }
        }
        for marker in markers{
            marker.setMarker()
            marker.map = map
            if mapViewType == .TerminalType && marker.isCorporateOffice {
                marker.zIndex = 1
                marker.opacity = 0.9
            }
            else {
                marker.zIndex = 0
                marker.opacity = 0.7
            }
        }
        addRadiusCircle()
    }
    func checkIfMarkerWithLocationExists(locationInfo: LocationInfo) -> Bool{
        var ifAlreadyExists = false
        for marker in markers{
            if marker.locationInfoArr.first?.longitude == locationInfo.longitude , marker.locationInfoArr.first?.latitude == locationInfo.latitude{
                marker.locationInfoArr.append(locationInfo)
                ifAlreadyExists = true
            }
        }
        return ifAlreadyExists
    }
    
    func addTractorList(_ tractorList: [TractorInfo])
    {
        markers.removeAll()
        map.clear()
        for location in tractorList {
            let marker = GoogleMapMarker()
            marker.opacity = 0.7
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.tractorInfo = location
            marker.map = map
            marker.setMarker()
            markers.append(marker)
        }
        addRadiusCircle()
    }
    
    func moveMaptoLocation(location: CLLocation){
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: map.camera.zoom)
        self.map.animate(to: camera)
    }
    
    
    func zoomMapToRadius() {
        
        if let center: CLLocationCoordinate2D = searchLocation?.coordinate{
            let meterRadius = CLLocationDistance(selectedRadius*1609)
            let n: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 0)
            let e: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 90)
            let s: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 180)
            let w: CLLocationCoordinate2D = GMSGeometryOffset(center, meterRadius, 270)
            
            var bounds: GMSCoordinateBounds = GMSCoordinateBounds.init()
            bounds = bounds.includingCoordinate(n).includingCoordinate(e).includingCoordinate(s).includingCoordinate(w)
            map.animate(with: GMSCameraUpdate.fit(bounds))
            zoomLevel = map.camera.zoom
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        searchLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        DispatchQueue.main.async { () -> Void in
            self.mapFilterDelegate?.mapFilter(sender: self)
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        searchLocation = getCurrentLocation()
        mapFilterDelegate?.mapFilter(sender: self)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(map.selectedMarker) {
            let oldMarker: GMSMarker? = change?[.oldKey] as? GMSMarker
            let newMarker: GMSMarker? = change?[.newKey] as? GMSMarker
            if newMarker == nil {
                detailViewArr.removeAll()
            }
            else {
                createMarkerDetailView(markerTapped: newMarker)
                moveMaptoLocation(location:CLLocation(latitude: (newMarker?.position.latitude)!, longitude: (newMarker?.position.longitude)!))
            }
            colorSelectedMarker(oldMarker: oldMarker, newMarker: newMarker)
            setupDetailCollectionViewHeight()
        }
    }
    func toggleMarkerColor(marker: GMSMarker?){
        if marker != nil, let googleMarker = marker as? GoogleMapMarker{
            googleMarker.toggleMarkerSelection()
        }
    }
    
    func colorSelectedMarker(oldMarker: GMSMarker?, newMarker: GMSMarker?) {
        let oldGoogleMarker = oldMarker as? GoogleMapMarker
        let newGoogleMarker = newMarker as? GoogleMapMarker
        oldGoogleMarker?.setMarker()
        newGoogleMarker?.colorMarkerGreen()
        
        if mapViewType == .TerminalType {
            oldGoogleMarker?.opacity = (oldGoogleMarker?.isCorporateOffice ?? false)! ? 0.9 : 0.7
            newGoogleMarker?.opacity = 1
            oldGoogleMarker?.zIndex = (oldGoogleMarker?.isCorporateOffice ?? false)! ? 1 : 0
            newGoogleMarker?.zIndex = 2
            
        } else {
            oldGoogleMarker?.opacity = 0.7
            newGoogleMarker?.opacity = 1
            oldGoogleMarker?.zIndex = 0
            newGoogleMarker?.zIndex = 1
        }
    }

    func createMarkerDetailView(markerTapped marker: GMSMarker?){
        if let selectedMarker =  marker as? GoogleMapMarker{
            if selectedMarker.locationInfoArr.count == 0 && selectedMarker.tractorInfo == nil {
                return
            }
            if let locInfo =  selectedMarker.locationInfoArr.first, mapViewType == .TerminalType{
                detailViewLocationInfo = locInfo
                detailViewArr.removeAll()
            }
            else{
                detailViewTractorInfo = selectedMarker.tractorInfo
                detailViewArr.removeAll()
            }
            detailViewArr.append(selectedMarker)
        }
    }
    
    func mapBtnTapped(forTractorAt index:IndexPath ){
        let selectedMarker = markers[index.item] as GMSMarker
        _ = mapView(map, didTap: selectedMarker)
        let location = CLLocation(latitude: selectedMarker.position.latitude, longitude: selectedMarker.position.longitude)
        moveMaptoLocation(location: location)
    }
    
    
    @IBAction func tractorSearchCallBtnPressed(){
        if let tratorInfo = detailViewTractorInfo{
            DataManager.sharedInstance.addNewCallLog(tratorInfo.tractorId!, userId:DataManager.sharedInstance.userName!)
        }
        UIUtils.callPhoneNumber(kdefaultTractorNumber)
    }
}


extension MapView : UITextFieldDelegate, UIPickerViewDataSource
{
    
    func createPickerView()
    {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(radiusList.index(of: String(selectedRadius))!, inComponent: 0, animated: false)

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.darkGray //UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(MapView.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MapView.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        radiusTextField.inputView = pickerView
        radiusTextField.inputAccessoryView = toolBar
    }

    @objc func doneClick() {

        radiusLbl.attributedText = String("Radius \(selectedRadius) mi").createAttributedString(subString: "\(selectedRadius) mi", subStringColor: .blue)

        radiusTextField.resignFirstResponder()

        mapFilterDelegate?.mapFilter(sender: self)
    }
    
    @objc func cancelClick() {
        radiusTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        createPickerView()
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


extension MapView: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        searchLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        DispatchQueue.main.async { () -> Void in
            self.mapFilterDelegate?.mapFilter(sender: self)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension MapView : UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
   
    func setupCollectionView(){
        setupCollectionIdentifierAndHeight()
        setupDetailCollectionViewHeight()
        detailCollectionView.allowsSelection = false
        detailCollectionViewheight.constant = 0
        detailCollectionViewContainer.layoutIfNeeded()
        
        detailCollectionView.register(UINib(nibName: "TractorCollectionMapCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TractorCollectionMapCell")
        detailCollectionView.register(UINib(nibName: "TractorCollectionGridCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TractorCollectionGridCell")
        
        detailCollectionView.register(UINib(nibName: "TerminalCollectionMapCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TerminalCollectionMapCell")
    }
    
    func setupCollectionIdentifierAndHeight(){
        if mapViewType == .TerminalType{
            cellIdentifier = "TerminalCollectionMapCell"
            detailCollectionViewCellHeight = kTerminalMapCellHeight
        }
        else{
            if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
                cellIdentifier = "TractorCollectionMapCell"
                detailCollectionViewCellHeight = kTractorMapCellHeight
            }
            else {
                cellIdentifier = "TractorCollectionGridCell"
                detailCollectionViewCellHeight = kTractorGridCellHeight
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == detailCollectionView{
            if scrollView.contentOffset.y < 0{
                UIView.animate(withDuration: 0.3) {
                    self.detailCollectionViewheight.constant = 0
                    self.detailCollectionViewContainer.layoutIfNeeded()
                }
            }
        }
    }
    
    func setupDetailCollectionViewHeight() {
        self.detailCollectionView.reloadData()
        detailCollectionView.layoutIfNeeded()
        let newHeight = min(view.frame.height*(2/3), detailCollectionView.contentSize.height)
        UIView.animate(withDuration: 0.3) {
            self.detailCollectionViewheight.constant = newHeight
            self.detailCollectionViewContainer.layoutIfNeeded()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mapViewType == .TerminalType{
            return detailViewArr.first?.locationInfoArr.count ?? 0
        }
        else{
            return detailViewArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if mapViewType == .TerminalType{
            return dequeueTerminalMapCell(collectionView:collectionView ,indexPath:indexPath)
        }
        else{
            return dequeueTractorGridCell(collectionView:collectionView,indexPath:indexPath)
        }
    }
    
    func dequeueTerminalMapCell(collectionView: UICollectionView, indexPath: IndexPath) -> TerminalCollectionMapCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier!, for: indexPath) as! TerminalCollectionMapCell

        let marker = detailViewArr.first
        if let locationInfo = marker?.locationInfoArr[indexPath.row]{
            cell.setLocationInfo(locationInfo: locationInfo)
        }
        return cell
    }
    
    func dequeueTractorGridCell(collectionView: UICollectionView, indexPath: IndexPath) -> TractorCollectionGridCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier!, for: indexPath) as! TractorCollectionGridCell
        let marker = detailViewArr[indexPath.row]
        if let tractorInfo = marker.tractorInfo{
            cell.setTractorInfo(tractorInfo: tractorInfo)
            cell.mapBtnView.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: detailCollectionViewCellHeight)
    }
}




