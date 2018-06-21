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
    var searchCompletionHandler: ((LoadBoardSearchInfo?)->Void)?
    
    var usStateDict = UIUtils.parsePlist(ofName: kUsStatepList) as? Dictionary<String, String>

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
            if lbSearchfilterType == .trailerType || lbSearchfilterType == .tractorTerminal || lbSearchfilterType == .tractorType ||
                lbSearchfilterType == .originLocation ||
                lbSearchfilterType == .destLocation{
                if let filterCancelButton = UIUtils.returnElement(withTag: index, from: filterCancelBtn){
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
        self.searchCompletionHandler?(lbSearchInfo)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetBtnPressed(_ sender: UIControl) {
        AppPrefData.sharedInstance.tractorSearchDict = nil
        if let defaultLoadBoardInfo = DataManager.sharedInstance.fetchLoadBoardSearchFilterDefaultValues(){
            lbSearchInfo?.originCity = defaultLoadBoardInfo.originCity
            lbSearchInfo?.originState = defaultLoadBoardInfo.originState
            lbSearchInfo?.originStateAbbrev = defaultLoadBoardInfo.originStateAbbrev
            
            lbSearchInfo?.destCity = defaultLoadBoardInfo.destCity
            lbSearchInfo?.destState = defaultLoadBoardInfo.destState
            lbSearchInfo?.destStateAbbrev = defaultLoadBoardInfo.destStateAbbrev
            
            lbSearchInfo?.trailerTypeId = defaultLoadBoardInfo.trailerTypeId
            lbSearchInfo?.trailerTypeDesc = defaultLoadBoardInfo.trailerTypeDesc
            
            lbSearchInfo?.terminalId = defaultLoadBoardInfo.terminalId
            lbSearchInfo?.tractorId = defaultLoadBoardInfo.tractorId
            lbSearchInfo?.tractorType.removeAll()
        }
        DataManager.sharedInstance.loadBoardSearchInfo = lbSearchInfo
        AppPrefData.sharedInstance.saveAllData()
        reloadLabels()
        checkIfSavedFiltersSelected()
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
        
        func presentAutoCompleteController(filterType: GMSPlacesAutocompleteTypeFilter){
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            let filter = GMSAutocompleteFilter()
            filter.type = filterType
            autocompleteController.autocompleteFilter = filter
            present(autocompleteController, animated:true, completion: nil)
        }
        
        let lbSearchfilterType = LoadBoardSearchFilterType(rawValue: sender.tag)!
        switch lbSearchfilterType {
        case .originLocation, .destLocation:
            gmsAutocompleteViewType = LBgmsAutocompleteViewType(rawValue: lbSearchfilterType.rawValue)
            presentAutoCompleteController(filterType: .city)
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
        case .originLocation:
            lbSearchInfo?.originCity = ""
            lbSearchInfo?.originState = ""
            lbSearchInfo?.originStateAbbrev = ""
        case .destLocation:
            lbSearchInfo?.destCity = ""
            lbSearchInfo?.destState = ""
            lbSearchInfo?.destStateAbbrev = ""
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
                (lbSearchInfo?.originStateAbbrev)! == defaultLoadBoardInfo.originStateAbbrev &&
                (lbSearchInfo?.destCity)! == defaultLoadBoardInfo.destCity &&
                (lbSearchInfo?.destState)! == defaultLoadBoardInfo.destState &&
                (lbSearchInfo?.destStateAbbrev)! == defaultLoadBoardInfo.destStateAbbrev
            
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
            let originCity = "\(loadBoardSearchInfo.originCity)"
            let originStateAbbrev = "\(loadBoardSearchInfo.originStateAbbrev)"
            let delimeter = (!originCity.isBlank() && !originStateAbbrev.isBlank()) ? "," : ""
            value = "\(originCity)\(delimeter)\(originStateAbbrev)"
        case .destLocation:
            let destCity = "\(loadBoardSearchInfo.destCity)"
            let destStateAbbrev = "\(loadBoardSearchInfo.destStateAbbrev)"
            let delimeter = (!destCity.isBlank() && !destStateAbbrev.isBlank()) ? "," : ""
            value = "\(destCity)\(delimeter)\(destStateAbbrev)"
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
        filterPopupVC?.selectedList = lbSearchInfo?.tractorType ?? []
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
        let isStateSelected: Bool = place.types.contains("administrative_area_level_1")
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            if let address = response?.firstResult(){
                if self.gmsAutocompleteViewType == .EOriginLocation{
                    self.lbSearchInfo?.originCity = !isStateSelected ? ((address.locality) ?? "") : ""
                    let administrativeArea = address.administrativeArea ?? ""
                    self.lbSearchInfo?.originState = administrativeArea
                    if !administrativeArea.isBlank(){
                        self.lbSearchInfo?.originStateAbbrev = self.usStateDict?[administrativeArea.uppercased()] ?? ""
                    }
                    self.reloadLabel(at: LoadBoardSearchFilterType.originLocation.rawValue)
                }
                else if self.gmsAutocompleteViewType == .EDestLocation{
                    self.lbSearchInfo?.destCity = !isStateSelected ? ((address.locality) ?? "") : ""
                    let administrativeArea = address.administrativeArea ?? ""
                    self.lbSearchInfo?.destState = administrativeArea
                    if !administrativeArea.isBlank(){
                        self.lbSearchInfo?.destStateAbbrev = self.usStateDict?[administrativeArea.uppercased()] ?? ""
                    }
                    self.reloadLabel(at: LoadBoardSearchFilterType.destLocation.rawValue)
                }
            }
            viewController.dismiss(animated: true, completion: nil)
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

