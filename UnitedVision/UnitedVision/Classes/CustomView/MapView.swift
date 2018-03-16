//
//  MapView.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

let kTractorViewHeight : CGFloat = 104
let kTerminalViewHeight : CGFloat = 95

protocol MapFilterDelegate: class {
    func mapFilter(sender: MapView)
}

class GoogleMapMarker : GMSMarker{
    var locationInfo : LocationInfo?
    var tractorInfo : TractorInfo?
}

class MapView: UIView, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate {
    
    
    @IBOutlet var terminalDetailView: UIView!
    @IBOutlet var terminalDetailViewHeight: NSLayoutConstraint!
    @IBOutlet var terminalDetailViewAddressLbl : UILabel!
    
    @IBOutlet var tractorDetailView: UIView!
    @IBOutlet var tractorDetailViewHeight: NSLayoutConstraint!
    @IBOutlet var tractorDtlViewTerminalLbl : UILabel!
    @IBOutlet var tractorDtlViewDestLbl : UILabel!
    @IBOutlet var tractorDtlViewTractorLbl : UILabel!
    @IBOutlet var tractorDtlViewTrailerLbl : UILabel!
    @IBOutlet var tractorDtlViewTrailerLenLbl : UILabel!
    @IBOutlet var tractorDtlViewDistLbl : UILabel!
    @IBOutlet var tractorDtlViewStatusLbl : UILabel!
    @IBOutlet var tractorDtlViewLoadedImgView : UIImageView!
    @IBOutlet var tractorDtlViewHazmatImgView : UIImageView!
    
    @IBOutlet var map: GMSMapView!
    var markers = [GoogleMapMarker]()
    
    @IBOutlet var myLocationBtnOutlet: UIButton!
    var myLocationBtn : UIButton?
    
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
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
    
    func initialSetup(forType mapViewType : MapViewType)
    {
        
        self.mapViewType = mapViewType
        
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        map.settings.compassButton = true
        map.delegate = self
        setupUpMyLocationBtn()
        searchLocation = self.getCurrentLocation()
        
        radiusList = DataManager.sharedInstance.getRadiusList()
        
        radiusTextField.text = String("Radius: \(selectedRadius) mi")
        
        terminalDetailViewHeight.constant = 0
        tractorDetailViewHeight.constant = 0
        
        terminalDetailView.isHidden = mapViewType == .TerminalType ? false : true
        tractorDetailView.isHidden =  mapViewType == .TractorType ? false : true
        
        zoomLevel = kDefaultZoom
        
        self.zoomMapToRadius()
        addObserver(self, forKeyPath: #keyPath(map.selectedMarker), options: [.old, .new], context: nil)
        
    }
    
    
    func setupUpMyLocationBtn(){
        
        myLocationBtnOutlet.imageView?.contentMode = .scaleAspectFit
        myLocationBtnOutlet.layer.masksToBounds = true
        myLocationBtnOutlet.layer.shouldRasterize = true
        myLocationBtnOutlet.layer.cornerRadius = myLocationBtnOutlet.frame.width/2
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
    
    
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let userLocation = locations.last
    //        currentLocation = userLocation
    //        if searchLocation == nil {
    //            searchLocation = userLocation!
    //            moveMaptoLocation(location: currentLocation!)
    //        }
    //        locationManager.stopUpdatingLocation()
    //
    //    }
    
    
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
        self.radiusTextField.text = String("Radius: \(selectedRadius) mi")
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
    func hideDetailView(){
        tractorDetailView.isHidden = true
        terminalDetailView.isHidden = true
        tractorDetailViewHeight.constant = 0
        terminalDetailViewHeight.constant = 0
        terminalDetailView.layoutIfNeeded()
    }
    
    func addRadiusCircle()
    {
        if searchLocation != nil{
            let meterRadius = selectedRadius * 1609
            let circle: GMSCircle = GMSCircle(position: (searchLocation?.coordinate)!,
                                              radius: CLLocationDistance(meterRadius))
            circle.map = map
        }
    }
    
    func addLocationList(_ locationList: [LocationInfo])
    {
        markers.removeAll()
        map.clear()
        hideDetailView()
        for location in locationList {
            let marker = GoogleMapMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: -location.longitude)
            marker.locationInfo = location
            marker.map = map
            markers.append(marker)
        }
        addRadiusCircle()
    }
    
    func addTractorList(_ tractorList: [TractorInfo])
    {
        markers.removeAll()
        map.clear()
        hideDetailView()
        for location in tractorList {
            let marker = GoogleMapMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.tractorInfo = location
            marker.map = map
            markers.append(marker)
        }
        addRadiusCircle()
    }
    
    func moveMaptoLocation(location: CLLocation){
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: self.zoomLevel)
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
            
            if oldMarker == newMarker {
                oldMarker?.icon = GMSMarker.markerImage(with: nil)
                hideDetailView()
            }
            else {
                colorSelectedMarker(oldMarker: oldMarker, newMarker: newMarker)
                createMarkerDetailView(markerTapped: newMarker)
            }
        }
    }
    
    func colorSelectedMarker(oldMarker: GMSMarker?, newMarker: GMSMarker?) {
            oldMarker?.icon = GMSMarker.markerImage(with: nil)
            newMarker?.icon = GMSMarker.markerImage(with: .green)
    }

    func createMarkerDetailView(markerTapped marker: GMSMarker?){
        if let selectedMarker =  marker as? GoogleMapMarker{
            if let htmlStr = selectedMarker.locationInfo?.detail , mapViewType == .TerminalType{
                terminalDetailViewAddressLbl.attributedText = htmlStr.htmlToAttributedString
                terminalDetailViewHeight.constant = kTerminalViewHeight
                tractorDetailView.isHidden = true
                terminalDetailView.isHidden = false
            }
            else{
                fillDataInTractorDetailView(tractorInfo: selectedMarker.tractorInfo)
                tractorDetailViewHeight.constant = kTractorViewHeight
                tractorDetailView.isHidden = false
            }
        }
    }
    
    func fillDataInTractorDetailView(tractorInfo : TractorInfo?) {
        if tractorInfo != nil {
            tractorDtlViewTerminalLbl.text = tractorInfo?.terminal
            tractorDtlViewDestLbl.text = tractorInfo?.destinationCity
            tractorDtlViewTractorLbl.text = tractorInfo?.tractorType
            tractorDtlViewTrailerLbl.text = tractorInfo?.trailerType
            tractorDtlViewTrailerLenLbl.text = tractorInfo?.trailerLength
            tractorDtlViewDistLbl.text = tractorInfo?.distanceFromShipper
            tractorDtlViewStatusLbl.text = tractorInfo?.status
            tractorDtlViewLoadedImgView.image = UIUtils.returnCheckOrCrossImage(str: (tractorInfo?.loaded) ?? "")
            tractorDtlViewHazmatImgView.image = UIUtils.returnCheckOrCrossImage(str: (tractorInfo?.hazmat) ?? "")
        }
    }
    
    func mapBtnTapped(forTractorAt index:IndexPath ){
        let selectedMarker = markers[index.section] as GMSMarker
        _ = mapView(map, didTap: selectedMarker)
        let location = CLLocation(latitude: selectedMarker.position.latitude, longitude: selectedMarker.position.longitude)
        moveMaptoLocation(location: location)
    }
    
    @IBAction func terminalSearchCallBtnPressed(){
        
    }
    @IBAction func tractorSearchCallBtnPressed(){
        
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
        
        radiusTextField.text = String("Radius: \(selectedRadius) mi")
        radiusTextField.resignFirstResponder()
        
        self.mapFilterDelegate?.mapFilter(sender: self)
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


extension MapView: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        searchLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        DispatchQueue.main.async { () -> Void in
            
            //            self.mapView.moveMaptoLocation(location: self.searchLocation!)
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




