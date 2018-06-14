//
//  LoadBoardFilterVC.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 13/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

let numberOfLoadBoardFilterLbls = 5
let kLoadBoardFilterTitle = "LOADBOARD SEARCH FILTER"

enum LBgmsAutocompleteViewType: Int{
    case EOriginLocation = 0
    case EDestLocation = 1
}

class LoadBoardFilterVC: BaseViewController, SideMenuLogOutDelegate {
    
    @IBOutlet weak var topApplyBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var checkBoxImg: UIImageView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var topApplyBtnView: UIView!
    @IBOutlet weak var bottomApplyBtnView: UIView!
    
    @IBOutlet weak var saveDefaultsView: UIView!
    
    @IBOutlet weak var resetBtnView: UIView!
    @IBOutlet var filterLbl: [UILabel]!
    @IBOutlet var filterCancelBtn: [UIButton]!
    
    @IBOutlet weak var hazmatCheckImgView: UIImageView!
    
    var gmsAutocompleteViewType: LBgmsAutocompleteViewType?
    
    var lbSearchInfo : LoadBoardSearchInfo?
    var filterPopupVC : FilterPopupViewController?
    var searchCompletionHandler: ((LoadBoardSearchInfo)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        initiateFilterPopupVC()
        reloadLabels()
        checkIfSavedFiltersSelected()
        setTitleView(withTitle: kLoadBoardFilterTitle, Frame:nil)
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
    
    func reloadLabels() {
        for index in 0...numberOfLoadBoardFilterLbls{
            reloadLabel(at: index)
        }
    }
    
    func reloadLabel(at index:Int) {
        
        if index == LoadBoardSearchFilterType.hazmat.rawValue{
            hazmatCheckImgView.isHighlighted = (lbSearchInfo?.hazmat)!
        }
        else{
            let lbSearchfilterType = LoadBoardSearchFilterType(rawValue: index)
            let filterLblValue = getValue(for: lbSearchfilterType!, from: lbSearchInfo!) as! String
            filterLbl[index].text = filterLblValue
            if lbSearchfilterType == .trailerType || lbSearchfilterType == .tractorTerminal || lbSearchfilterType == .tractorType{
                if let filterCancelButton = UIUtils.returnElement(with: index, from: filterCancelBtn){
                    filterCancelButton.isHidden = filterLblValue.isEmpty
                }
            }
        }
        checkIfSavedFiltersSelected()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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


extension LoadBoardFilterVC{
    
    @IBAction func applyBtnPressed(_ sender: UIControl) {
        self.searchCompletionHandler?(lbSearchInfo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetBtnPressed(_ sender: UIControl) {
        var isCurrentLocAvail: Bool = false
        var currentLocation: CLLocation?
        
        func resetFilterToDefaultValues(){
            AppPrefData.sharedInstance.tractorSearchDict = nil
            if let defaultLoadBoardInfo = DataManager.sharedInstance.fetchLoadBoardSearchFilterDefaultValues(){
                if !isCurrentLocAvail{
                    lbSearchInfo?.originCity = defaultLoadBoardInfo.originCity
                    lbSearchInfo?.originState = defaultLoadBoardInfo.originState
                    lbSearchInfo?.originZip = defaultLoadBoardInfo.originZip
                    lbSearchInfo?.originLatitude = defaultLoadBoardInfo.originLatitude
                    lbSearchInfo?.originLongitude = defaultLoadBoardInfo.originLongitude
                    
                    lbSearchInfo?.destCity = defaultLoadBoardInfo.destCity
                    lbSearchInfo?.destState = defaultLoadBoardInfo.destState
                    lbSearchInfo?.destZip = defaultLoadBoardInfo.destZip
                    lbSearchInfo?.destLatitude = defaultLoadBoardInfo.destLatitude
                    lbSearchInfo?.destLongitude = defaultLoadBoardInfo.destLongitude
                }
                lbSearchInfo?.trailerTypeId = defaultLoadBoardInfo.trailerTypeId
                lbSearchInfo?.trailerTypeDesc = defaultLoadBoardInfo.trailerTypeDesc
                lbSearchInfo?.terminalId = defaultLoadBoardInfo.terminalId
                lbSearchInfo?.tractorType.removeAll()
                lbSearchInfo?.hazmat = false
            }
            DataManager.sharedInstance.loadBoardSearchInfo = lbSearchInfo
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
                    self.lbSearchInfo?.originCity = (address?.locality) ?? ""
                    self.lbSearchInfo?.originState = (address?.administrativeArea) ?? ""
                    self.lbSearchInfo?.originZip = (address?.postalCode) ?? ""
                    self.lbSearchInfo?.originLatitude = currentLocation?.coordinate.latitude ?? 0
                    self.lbSearchInfo?.originLongitude = currentLocation?.coordinate.longitude ?? 0
                    
                    self.lbSearchInfo?.destCity = (address?.locality) ?? ""
                    self.lbSearchInfo?.destState = (address?.administrativeArea) ?? ""
                    self.lbSearchInfo?.destZip = (address?.postalCode) ?? ""
                    self.lbSearchInfo?.destLatitude = currentLocation?.coordinate.latitude ?? 0
                    self.lbSearchInfo?.destLongitude = currentLocation?.coordinate.longitude ?? 0
                    
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
            lbSearchInfo = DataManager.sharedInstance.fetchLoadBoardSearchFilterDefaultValues()
            reloadLabels()
        }
        DataManager.sharedInstance.loadBoardSearchInfo = lbSearchInfo
        AppPrefData.sharedInstance.saveAllData()
        checkBoxImg.isHighlighted = !checkBoxImg.isHighlighted
    }
    
    @IBAction func filterBtnTapped(_ sender: UIButton) {
        let lbSearchfilterType = LoadBoardSearchFilterType(rawValue: sender.tag)!
        switch lbSearchfilterType {
        case .originLocation, .destLocation:
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            gmsAutocompleteViewType = LBgmsAutocompleteViewType(rawValue: lbSearchfilterType.rawValue)
            present(autocompleteController, animated:true, completion: nil)
        case .tractorType:
            showFilterPopup(lbSearchfilterType)
        case .trailerType, .tractorTerminal:
            showFilterSearchScreen(lbSearchfilterType)
        case .hazmat:
            lbSearchInfo?.hazmat = !(lbSearchInfo?.hazmat)!
            reloadLabel(at: LoadBoardSearchFilterType.hazmat.rawValue)
        }
    }
    @IBAction func filterCancelBtnTapped(_ sender: UIButton) {
        let lbSearchfilterType = LoadBoardSearchFilterType(rawValue: sender.tag)!
        switch lbSearchfilterType {
        case .tractorType:
            lbSearchInfo?.tractorType.removeAll()
        case .trailerType:
            lbSearchInfo?.trailerTypeId = ""
            lbSearchInfo?.trailerTypeDesc = ""
        case .tractorTerminal:
            lbSearchInfo?.terminalId = ""
        default:
            break
        }
        reloadLabel(at: sender.tag)
    }
    func checkIfSavedFiltersSelected() {
        if let defaultLoadBoardInfo = DataManager.sharedInstance.fetchLoadBoardSearchFilterDefaultValues(){
            var result : Bool = true
            result = (lbSearchInfo?.hazmat)! == defaultLoadBoardInfo.hazmat &&
                (lbSearchInfo?.showLocal)! == defaultLoadBoardInfo.showLocal &&
                (lbSearchInfo?.terminalId)! == defaultLoadBoardInfo.terminalId &&
                (lbSearchInfo?.tractorId)! == defaultLoadBoardInfo.tractorId &&
                (lbSearchInfo?.tractorType)! == defaultLoadBoardInfo.tractorType &&
                (lbSearchInfo?.trailerTypeId)! == defaultLoadBoardInfo.trailerTypeId &&
                (lbSearchInfo?.originCity)! == defaultLoadBoardInfo.originCity &&
                (lbSearchInfo?.originState)! == defaultLoadBoardInfo.originState &&
                (lbSearchInfo?.originZip)! == defaultLoadBoardInfo.originZip &&
                (lbSearchInfo?.originLatitude)! == defaultLoadBoardInfo.originLatitude &&
                (lbSearchInfo?.originLongitude)! == defaultLoadBoardInfo.originLongitude &&
                (lbSearchInfo?.destCity)! == defaultLoadBoardInfo.destCity &&
                (lbSearchInfo?.destState)! == defaultLoadBoardInfo.destState &&
                (lbSearchInfo?.destZip)! == defaultLoadBoardInfo.destZip &&
                (lbSearchInfo?.destLatitude)! == defaultLoadBoardInfo.destLatitude &&
                (lbSearchInfo?.destLongitude)! == defaultLoadBoardInfo.destLongitude
            
            if lbSearchInfo?.tractorType.count != defaultLoadBoardInfo.tractorType.count {
                result = false
            }
            else{
                for (index, value) in (lbSearchInfo?.tractorType.enumerated())! {
                    result = (value == defaultLoadBoardInfo.tractorType[index]) && result
                }
            }
            checkBoxImg.isHighlighted = result
        }
    }
}

extension LoadBoardFilterVC{
    
    func getValue(for lbSearchfilterType: LoadBoardSearchFilterType,from loadBoardSearchInfo: LoadBoardSearchInfo) -> Any
    {
        var value: Any
        switch lbSearchfilterType {
        case .originLocation:
            value = "\(loadBoardSearchInfo.originCity), \(loadBoardSearchInfo.originState), \(loadBoardSearchInfo.originZip)" //searchInfo.city + searchInfo.state + searchInfo.zip
        case .destLocation:
            value = "\(loadBoardSearchInfo.destCity), \(loadBoardSearchInfo.destState), \(loadBoardSearchInfo.destZip)" //searchInfo.city + searchInfo.state + searchInfo.zip
        case .tractorTerminal:
            value = loadBoardSearchInfo.terminalId
        case .tractorType:
            var tractorTypeList = loadBoardSearchInfo.tractorType
            if tractorTypeList.contains("All"){
                tractorTypeList.removeAll()
                tractorTypeList.append("All")
            }
            value = tractorTypeList.joined(separator: ",")
        case .trailerType:
            value = loadBoardSearchInfo.trailerTypeDesc
        case .hazmat:
            value = loadBoardSearchInfo.hazmat
        }
        return value
    }
    
    func showFilterPopup(_ lbSearchfilterType: LoadBoardSearchFilterType)
    {
        filterPopupVC?.lbSearchfilterType = lbSearchfilterType
        filterPopupVC?.tractorCompletionHandler = {(selectedTractorType) in
            self.lbSearchInfo?.tractorType = selectedTractorType
            self.reloadLabel(at:LoadBoardSearchFilterType.tractorType.rawValue)
        }
       
        filterPopupVC?.modalTransitionStyle = .crossDissolve
        filterPopupVC?.modalPresentationStyle = .overCurrentContext
        self.present(filterPopupVC!, animated: true, completion: nil)
    }
    
    func showFilterSearchScreen(_ lbSearchfilterType: LoadBoardSearchFilterType)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "FilterSearchViewController") as! FilterSearchViewController
        viewCtrl.loadBoardSearchFilterType = lbSearchfilterType
        
        viewCtrl.completionHandler = {(selectedValue) in
            if lbSearchfilterType == .tractorTerminal {
                self.lbSearchInfo?.terminalId = (selectedValue ?? "") as! String
            }
            else if lbSearchfilterType == .trailerType{
                if let trailerInfo = selectedValue as? TrailerInfo{
                    self.lbSearchInfo?.trailerTypeId = trailerInfo.id!
                    self.lbSearchInfo?.trailerTypeDesc = trailerInfo.descr!
                }
            }
            self.reloadLabel(at: lbSearchfilterType.rawValue)
        }
        viewCtrl.modalTransitionStyle = .crossDissolve
        viewCtrl.modalPresentationStyle = .overCurrentContext
        self.present(viewCtrl, animated: true, completion: nil)
    }
}



extension LoadBoardFilterVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        if gmsAutocompleteViewType == .EOriginLocation{
            self.lbSearchInfo?.originLatitude = place.coordinate.latitude
            self.lbSearchInfo?.originLongitude = place.coordinate.longitude
        }
        else if gmsAutocompleteViewType == .EDestLocation{
            self.lbSearchInfo?.destLatitude = place.coordinate.latitude
            self.lbSearchInfo?.destLongitude = place.coordinate.longitude
        }
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            let address = response?.firstResult()
            if self.gmsAutocompleteViewType == .EOriginLocation{
                self.lbSearchInfo?.originCity = (address?.locality) ?? ""
                self.lbSearchInfo?.originState = (address?.administrativeArea) ?? ""
                self.lbSearchInfo?.originZip = (address?.postalCode) ?? ""
                self.reloadLabel(at: LoadBoardSearchFilterType.originLocation.rawValue)
            }
            else if self.gmsAutocompleteViewType == .EDestLocation{
                self.lbSearchInfo?.destCity = (address?.locality) ?? ""
                self.lbSearchInfo?.destState = (address?.administrativeArea) ?? ""
                self.lbSearchInfo?.destZip = (address?.postalCode) ?? ""
                self.reloadLabel(at: LoadBoardSearchFilterType.destLocation.rawValue)
            }
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

