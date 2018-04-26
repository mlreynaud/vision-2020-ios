
//  TractorFilterViewController.swift
//  UnitedVision
//
//  Created by Agilink on 20/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

let numberOfFilterLbls = 7
let kTractorFilterTitle = "TRACTOR SEARCH FILTER"

let kLoadedViewHeight: CGFloat = 50
let kLoadedTopBottomPadding: CGFloat = 4

class TractorFilterViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource,SideMenuLogOutDelegate  {
   
    var searchInfo : TractorSearchInfo?
    
    var radiusList : [String] = []
    
    @IBOutlet weak var loadedView: UIView!
    @IBOutlet weak var loadedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var loadedViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topApplyBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var checkBoxImg: UIImageView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var topApplyBtnView: UIView!
    @IBOutlet weak var bottomApplyBtnView: UIView!
    
    var pickerToolbarView : UIView!
    var pickerView : UIPickerView?
    var toolBar : UIToolbar?
    
    var filterPopupVC : FilterPopupViewController?
    
    var searchCompletionHandler: ((TractorSearchInfo)->Void)?
    
    @IBOutlet weak var saveDefaultsView: UIView!
    
    @IBOutlet weak var resetBtnView: UIView!
    @IBOutlet var filterLbl: [UILabel]!
    @IBOutlet var filterCancelBtn: [UIButton]!
    
    @IBOutlet weak var loadedCheckImgView: UIImageView!
    @IBOutlet weak var hazmatCheckImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchInfo = DataManager.sharedInstance.returnFilterValues()
        radiusList = DataManager.sharedInstance.getRadiusList()
        createPickerView(forSize:view.frame.size)
        initiateFilterPopupVC()
        reloadLabels()
        checkIfSavedFiltersSelected()
        setTitleView(withTitle: kTractorFilterTitle, Frame:nil)
        setupLoadedView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        repositionApplyBtn(size: view.frame.size)
    }
    
    func initiateFilterPopupVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        filterPopupVC = storyBoard.instantiateViewController(withIdentifier: "FilterPopupViewController") as? FilterPopupViewController
    }
    
    func sideMenuLogOutPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setupLoadedView(){
        let isLoadedVisible = DataManager.sharedInstance.userType.loadedAccess
        if isLoadedVisible{
            loadedView.isHidden = false
            loadedViewHeight.constant = kLoadedViewHeight
            loadedViewTopConstraint.constant = kLoadedTopBottomPadding
        }
        else{
            loadedView.isHidden = true
            loadedViewHeight.constant = 0
            loadedViewTopConstraint.constant = 0
        }
    }
    
    func reloadLabels() {
        for index in 0...numberOfFilterLbls{
            reloadLabel(at: index)
        }
    }
    
    func reloadLabel(at index:Int) {
        if index == FilterType.loaded.rawValue{
            loadedCheckImgView.isHighlighted = (searchInfo?.loaded)!
        }
        else if index == FilterType.hazmat.rawValue{
            hazmatCheckImgView.isHighlighted = (searchInfo?.hazmat)!
        }
        else{
            let filterType = FilterType(rawValue: index)
            let filterLblValue = getValue(for: filterType!, from: searchInfo!) as! String
            filterLbl[index].text = filterLblValue
            if filterType == .trailerType || filterType == .tractorTerminal || filterType == .status || filterType == .tractorType{
                if let filterCancelButton = UIUtils.returnElement(with: index, from: filterCancelBtn){
                    filterCancelButton.isHidden = filterLblValue.isEmpty
                }
            }
        }
        checkIfSavedFiltersSelected()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        cancelClick()
        createPickerView(forSize: size)
        repositionApplyBtn(size: size)
    }
    
    func repositionApplyBtn(size: CGSize){
        if UIDevice.current.orientation.isLandscape{
            bottomApplyBtnView.isHidden = false
            bottomStackView.addArrangedSubview(bottomApplyBtnView)
            topApplyBtnHeight.constant = 0
        }
        else{
            bottomApplyBtnView.isHidden = true
            bottomStackView.removeArrangedSubview(bottomApplyBtnView)
            topApplyBtnHeight.constant = 50
        }
    }
}

extension TractorFilterViewController{
    
    @IBAction func applyBtnPressed(_ sender: UIControl) {
        self.searchCompletionHandler?(searchInfo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetBtnPressed(_ sender: UIControl) {
        var isCurrentLocAvail: Bool = false
        var currentLocation: CLLocation?

        func resetFilterToDefaultValues(){
            AppPrefData.sharedInstance.searchDict = nil
            if let defaultTractorInfo = DataManager.sharedInstance.fetchFilterDefaultValues(){
                if !isCurrentLocAvail{
                    searchInfo?.city = defaultTractorInfo.city
                    searchInfo?.state = defaultTractorInfo.state
                    searchInfo?.zip = defaultTractorInfo.zip
                    searchInfo?.latitude = defaultTractorInfo.latitude
                    searchInfo?.longitude = defaultTractorInfo.longitude
                }
                searchInfo?.radius = defaultTractorInfo.radius
                searchInfo?.trailerTypeId = defaultTractorInfo.trailerTypeId
                searchInfo?.trailerTypeDesc = defaultTractorInfo.trailerTypeDesc
                searchInfo?.terminalId = defaultTractorInfo.terminalId
                searchInfo?.status.removeAll()
                searchInfo?.tractorType.removeAll()
                searchInfo?.loaded = false
                searchInfo?.hazmat = false
            }
            DataManager.sharedInstance.tractorSearchInfo = searchInfo
            AppPrefData.sharedInstance.saveAllData()
            reloadLabels()
            checkIfSavedFiltersSelected()
        }
        
        if LocationManager.sharedInstance.checkLocationAuthorizationStatus() {
            if let userLocation = DataManager.sharedInstance.userLocation {
                currentLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                LoadingView.shared.showOverlay()
                let geocoder: GMSGeocoder = GMSGeocoder()
                geocoder.reverseGeocodeCoordinate(currentLocation!.coordinate) { (response, error) in
                    LoadingView.shared.hideOverlayView()
                    isCurrentLocAvail = true
                    let address = response?.firstResult()
                    self.searchInfo?.city = (address?.locality) ?? ""
                    self.searchInfo?.state = (address?.administrativeArea) ?? ""
                    self.searchInfo?.zip = (address?.postalCode) ?? ""
                    self.searchInfo?.latitude = currentLocation?.coordinate.latitude ?? 0
                    self.searchInfo?.longitude = currentLocation?.coordinate.longitude ?? 0
                    resetFilterToDefaultValues()
                }
            }
        }
        else{
            resetFilterToDefaultValues()
        }
    }
    
    @IBAction func saveDefaultViewTapped(_ sender: Any) {
        if checkBoxImg.isHighlighted{
            searchInfo = DataManager.sharedInstance.fetchFilterDefaultValues()
            reloadLabels()
        }
        DataManager.sharedInstance.tractorSearchInfo = searchInfo
        AppPrefData.sharedInstance.saveAllData()
        checkBoxImg.isHighlighted = !checkBoxImg.isHighlighted
    }
    
    @IBAction func filterBtnTapped(_ sender: UIButton) {
        let filterType = FilterType(rawValue: sender.tag)!
        switch filterType {
        case .searchLocation:
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated:true, completion: nil)
        case .radius:
            pickerToolbarView.isHidden = false
            pickerToolbarView.frame =  CGRect(x:0, y: view.bounds.size.height - 250 , width: view.bounds.size.width, height:250)
            toolBar?.frame = CGRect(x:0, y:0 , width: view.bounds.size.width, height:50)
        case .status, .tractorType:
            showFilterPopup(filterType)
        case .trailerType, .tractorTerminal:
            showFilterSearchScreen(filterType)
        case .loaded:
            searchInfo?.loaded = !(searchInfo?.loaded)!
            reloadLabel(at: FilterType.loaded.rawValue)
        case .hazmat:
            searchInfo?.hazmat = !(searchInfo?.hazmat)!
            reloadLabel(at: FilterType.hazmat.rawValue)
        }
    }
    @IBAction func filterCancelBtnTapped(_ sender: UIButton) {
        let filterType = FilterType(rawValue: sender.tag)!
        switch filterType {
        case .status:
            searchInfo?.status.removeAll()
        case .tractorType:
            searchInfo?.tractorType.removeAll()
        case .trailerType:
            searchInfo?.trailerTypeId = ""
            searchInfo?.trailerTypeDesc = ""
        case .tractorTerminal:
            searchInfo?.terminalId = ""
        default:
            break
        }
        reloadLabel(at: sender.tag)
    }
    func checkIfSavedFiltersSelected() {
        if let defaultTractorInfo = DataManager.sharedInstance.fetchFilterDefaultValues(){
            var result : Bool = true
            result = (searchInfo?.hazmat)! == defaultTractorInfo.hazmat &&
                (searchInfo?.loaded)! == defaultTractorInfo.loaded &&
                (searchInfo?.showLocal)! == defaultTractorInfo.showLocal &&
                (searchInfo?.terminalId)! == defaultTractorInfo.terminalId &&
                (searchInfo?.tractorId)! == defaultTractorInfo.tractorId &&
                (searchInfo?.tractorType)! == defaultTractorInfo.tractorType &&
                (searchInfo?.trailerTypeId)! == defaultTractorInfo.trailerTypeId &&
                (searchInfo?.radius)! == defaultTractorInfo.radius &&
                (searchInfo?.city)! == defaultTractorInfo.city &&
                (searchInfo?.state)! == defaultTractorInfo.state &&
                (searchInfo?.zip)! == defaultTractorInfo.zip &&
                (searchInfo?.latitude)! == defaultTractorInfo.latitude &&
                (searchInfo?.longitude)! == defaultTractorInfo.longitude
            if searchInfo?.status.count != defaultTractorInfo.status.count {
                result = false
            }
            else{
                for (index, value) in (searchInfo?.status.enumerated())! {
                    result = (value == defaultTractorInfo.status[index]) && result
                }
            }
            if searchInfo?.tractorType.count != defaultTractorInfo.tractorType.count {
                result = false
            }
            else{
                for (index, value) in (searchInfo?.tractorType.enumerated())! {
                    result = (value == defaultTractorInfo.tractorType[index]) && result
                }
            }
            checkBoxImg.isHighlighted = result
        }
    }
}

extension TractorFilterViewController{
    
    func getValue(for filterType: FilterType,from tractorSearchInfo: TractorSearchInfo) -> Any
    {
        var value: Any
        switch filterType {
        case .searchLocation:
            value = "\(tractorSearchInfo.city), \(tractorSearchInfo.state), \(tractorSearchInfo.zip)" //searchInfo.city + searchInfo.state + searchInfo.zip
        case .radius:
            value = "\(tractorSearchInfo.radius)mi"
        case .status:
            var statusList = tractorSearchInfo.status
            if statusList.contains("All"){
                statusList.removeAll()
                statusList.append("All")
            }
            value = statusList.joined(separator: ",")
        case .tractorTerminal:
            value = tractorSearchInfo.terminalId
        case .tractorType:
            var tractorTypeList = tractorSearchInfo.tractorType
            if tractorTypeList.contains("All"){
                tractorTypeList.removeAll()
                tractorTypeList.append("All")
            }
            value = tractorTypeList.joined(separator: ",")
        case .trailerType:
            value = tractorSearchInfo.trailerTypeDesc
        case .loaded:
            value = tractorSearchInfo.loaded
        case .hazmat:
            value = tractorSearchInfo.hazmat
        }
        return value
    }
    
    func showFilterPopup(_ filterType: FilterType)
    {
        filterPopupVC?.filterType = filterType
        filterPopupVC?.tractorCompletionHandler = {(selectedTractorValue) in
            self.searchInfo?.tractorType = selectedTractorValue
            self.reloadLabel(at:FilterType.tractorType.rawValue)
        }
        
        filterPopupVC?.statusFilterCompletionHandler = { (selectedStatusList) in
            self.searchInfo?.status = selectedStatusList
            self.reloadLabel(at:FilterType.status.rawValue)
        }
        filterPopupVC?.modalTransitionStyle = .crossDissolve
        filterPopupVC?.modalPresentationStyle = .overCurrentContext
        self.present(filterPopupVC!, animated: true, completion: nil)
    }
    
    func showFilterSearchScreen(_ filterType: FilterType)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "FilterSearchViewController") as! FilterSearchViewController
        viewCtrl.filterType = filterType
        
        viewCtrl.completionHandler = {(selectedValue) in
            if filterType == .tractorTerminal {
                self.searchInfo?.terminalId = (selectedValue ?? "") as! String
            }
            else if filterType == .trailerType{
                if let trailerInfo = selectedValue as? TrailerInfo{
                    self.searchInfo?.trailerTypeId = trailerInfo.id!
                    self.searchInfo?.trailerTypeDesc = trailerInfo.descr!
                }
            }
            self.reloadLabel(at: filterType.rawValue)
        }
        viewCtrl.modalTransitionStyle = .crossDissolve
        viewCtrl.modalPresentationStyle = .overCurrentContext
        self.present(viewCtrl, animated: true, completion: nil)
    }
}

extension TractorFilterViewController
{
    func createPickerView(forSize size: CGSize)
    {
        if toolBar != nil{
            toolBar?.removeFromSuperview()
        }
        if pickerView != nil{
            pickerView?.removeFromSuperview()
        }
        if pickerToolbarView != nil{
            pickerToolbarView.removeFromSuperview()
        }
        
        let yValue = size.height - 250
        let width = size.width
        
        pickerToolbarView = UIView(frame: CGRect(x:0, y: yValue , width: width, height:250))
        pickerView = UIPickerView(frame: CGRect(x:0, y: 40 , width: width, height:210))
        pickerView?.delegate = self
        pickerView?.dataSource = self
        pickerView?.showsSelectionIndicator = true
        pickerView?.backgroundColor = UIColor.white
        pickerView?.isUserInteractionEnabled = true
        pickerView?.selectRow(radiusList.index(of:(searchInfo?.radius)!)!, inComponent: 0, animated: false)
        
        toolBar = UIToolbar(frame: CGRect(x:0, y:0 , width: width, height:50))
        toolBar?.barStyle = .default
        toolBar?.isTranslucent = true
        toolBar?.tintColor = UIColor.darkGray //UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar?.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TractorFilterViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(TractorFilterViewController.cancelClick))
        toolBar?.items = nil
        toolBar?.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar?.isUserInteractionEnabled = true
        
        pickerToolbarView.addSubview(toolBar!)
        pickerToolbarView.addSubview(pickerView!)
        
        self.view.addSubview(pickerToolbarView)
        pickerToolbarView.isHidden = true
        pickerToolbarView.bringSubview(toFront: self.view)
    }
    
    @objc func doneClick() {
        let selectedRow = pickerView?.selectedRow(inComponent: 0) ?? 0
        searchInfo?.radius =  radiusList[selectedRow]
        pickerToolbarView.isHidden = true
        reloadLabel(at: FilterType.radius.rawValue)
    }
    
    @objc func cancelClick() {
        pickerToolbarView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        searchInfo?.radius =  radiusList[row]
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return radiusList[row]
    }
}

extension TractorFilterViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        self.searchInfo?.latitude = place.coordinate.latitude
        self.searchInfo?.longitude = place.coordinate.longitude
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            let address = response?.firstResult()
            self.searchInfo?.city = (address?.locality)!
            self.searchInfo?.state = (address?.administrativeArea)!
            self.searchInfo?.zip = (address?.postalCode) ?? ""
            self.reloadLabel(at: FilterType.searchLocation.rawValue)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error._domain)
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

