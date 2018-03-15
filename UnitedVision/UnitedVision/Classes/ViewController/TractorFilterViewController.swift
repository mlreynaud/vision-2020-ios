//
//  FilterViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 04/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//


import UIKit
import GoogleMaps
import GooglePlaces

class TractorFilterViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkboxSaveDefaults: UIButton!
    
    var searchInfo = TractorSearchInfo()
    
    var radiusList : [String] = []
    
    let filterList = ["Search Location", "Radius","Status", "Tractor Type", "Trailer Type", "Tractor Terminal"]
    
    let subList = ["Loaded", "HazMat"]
    var pickerToolbarView : UIView!
    
    var searchCompletionHandler: ((TractorSearchInfo)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()

        self.title = "Tractor Search Filter"
        // Do any additional setup after loading the view.
        
        searchInfo = DataManager.sharedInstance.tractorSearchInfo ?? DataManager.sharedInstance.fetchFilterDefaultValues()!
        
        radiusList = DataManager.sharedInstance.getRadiusList()
        self.createPickerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonAction(){
        
        DataManager.sharedInstance.tractorSearchInfo = searchInfo
        if checkboxSaveDefaults.isSelected {
            AppPrefData.sharedInstance.saveAllData()
        }
        
        self.searchCompletionHandler?(searchInfo)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonAction(){
        
        if let dict = AppPrefData.sharedInstance.searchDict {
            searchInfo = TractorSearchInfo(info: dict)
            DataManager.sharedInstance.tractorSearchInfo = searchInfo
        }
        self.tableView.reloadData()

    }
    
    @IBAction func saveDefaultsButtonAction(){
        self.checkboxSaveDefaults.isSelected = !checkboxSaveDefaults.isSelected
        
//        searchInfo = DataManager.sharedInstance.fetchFilterDefaultValues()
//        DataManager.sharedInstance.tractorSearchInfo = searchInfo
//        AppPrefData.sharedInstance.saveAllData()
        
//        self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TractorFilterViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterList.count + subList.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section < filterList.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as! FilterTableViewCell
        
            let filterType = FilterType(rawValue: indexPath.section)!

            let filterValue = self.getFilterTypeValue(filterType)
//            cell.titleLabel.text = filterList[indexPath.section] +
            
            cell.titleLabel.attributedText = (filterList[indexPath.section] + " " + filterValue).createAttributedString(subString: filterValue , subStringColor: kBlueColor)
            
            cell.clearHandler = {
                cell.titleLabel.attributedText = (self.filterList[indexPath.section] + " " + "").createAttributedString(subString: "" , subStringColor: kBlueColor)
                
//                cell.clearButton.isHidden = true
                
                if filterType == .tractorTerminal {
                    self.searchInfo.terminalId = ""
                }
                else if filterType == .trailerType {
                    self.searchInfo.trailerType = ""
                }
            }
            
            return cell;
        }
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxFilterTableCell", for: indexPath) as! CheckboxFilterTableCell
 
        let index = indexPath.section - filterList.count
        cell.titleLabel.text = subList[index]
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.section < filterList.count)
        {
            let filterType = FilterType(rawValue: indexPath.section)!
            switch filterType {
            case .searchLocation:
                let autocompleteController = GMSAutocompleteViewController()
                autocompleteController.delegate = self
                present(autocompleteController, animated:true, completion: nil)
            case .radius:
                pickerToolbarView.isHidden = false
                pickerToolbarView.frame =  CGRect(x:0, y: self.view.bounds.size.height - 250 , width: self.view.bounds.size.width, height:250)
            case .status:
                self.showFilterPopup(filterType, withMultiSelection:true )
            case .tractorType:
                self.showFilterPopup(filterType, withMultiSelection:false)
            case .trailerType:
                self.showFilterSearchScreen(filterType)
            case .tractorTerminal:
                self.showFilterSearchScreen(filterType)
            default:
                break
            }
        }
        
        
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! TerminalSearchViewController
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    func getFilterTypeValue(_ filterType: FilterType) -> String
    {
        var value : String
        switch filterType {
        case .searchLocation:
            value = String("\(searchInfo.city) \(searchInfo.state) \(searchInfo.zip) ") //searchInfo.city + searchInfo.state + searchInfo.zip
        case .radius:
            value = searchInfo.radius + "mi"
        case .status:
            value = searchInfo.status
        case .tractorTerminal:
            value = searchInfo.terminalId
        case .tractorType:
            value = searchInfo.tractorType
        case .trailerType:
            value = searchInfo.trailerType
    
            
        }
        
        return value
    }
    
    
    func showFilterPopup(_ filterType: FilterType, withMultiSelection allow: Bool)
    {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "FilterPopupViewController") as! FilterPopupViewController
            viewCtrl.filterType = filterType
            viewCtrl.tractorCompletionHandler = {(selectedTractorValue) in
            
                self.searchInfo.tractorType = selectedTractorValue
                self.tableView.reloadData()
            }
            
            //        self.providesPresentationContextTransitionStyle = true
            //        self.definesPresentationContext = true
            viewCtrl.modalPresentationStyle = .overCurrentContext
            
            self.present(viewCtrl, animated: true, completion: nil)
    }
    
    func showFilterSearchScreen(_ filterType: FilterType)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "FilterSearchViewController") as! FilterSearchViewController
        viewCtrl.filterType = filterType
        
        viewCtrl.completionHandler = {(selectedValue) in
            if filterType == .tractorTerminal {
                self.searchInfo.terminalId = selectedValue
            }
            else if filterType == .trailerType{
                self.searchInfo.trailerType = selectedValue
            }

            self.tableView.reloadData()

        }
        
        //        self.providesPresentationContextTransitionStyle = true
        //        self.definesPresentationContext = true
        viewCtrl.modalPresentationStyle = .overCurrentContext
        
        self.present(viewCtrl, animated: true, completion: nil)
    }
}

extension TractorFilterViewController
{
    func createPickerView()
    {
         let yValue = self.view.bounds.size.height - 250
         let width = self.view.bounds.size.width
        
        pickerToolbarView = UIView(frame: CGRect(x:0, y: yValue , width: width, height:250))
       let pickerView = UIPickerView(frame: CGRect(x:0, y: 50 , width: width, height:200))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor.white
        pickerView.isUserInteractionEnabled = true
        pickerView.selectRow(radiusList.index(of: String(searchInfo.radius))!, inComponent: 0, animated: false)
        
        let toolBar = UIToolbar(frame: CGRect(x:0, y:0 , width: width, height:50))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.darkGray //UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TractorFilterViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(TractorFilterViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        pickerToolbarView.addSubview(toolBar)
        pickerToolbarView.addSubview(pickerView)
        
        self.view.addSubview(pickerToolbarView)
        pickerToolbarView.isHidden = true
        pickerToolbarView.bringSubview(toFront: self.view)
//        radiusTextField.inputView = pickerView
//        radiusTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        
        DataManager.sharedInstance.tractorSearchInfo?.radius = String(searchInfo.radius)
        pickerToolbarView.isHidden = true

        tableView.reloadData()
    }
    
    @objc func cancelClick() {
//        radiusTextField.resignFirstResponder()
        pickerToolbarView.isHidden = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        searchInfo.radius =  radiusList[row]
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return radiusList[row]
    }
}

extension TractorFilterViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        viewController.dismiss(animated: true, completion: nil)
        self.searchInfo.latitude = place.coordinate.latitude
        self.searchInfo.longitude = place.coordinate.longitude
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            let address = response?.firstResult()
            self.searchInfo.city = (address?.locality)!
            self.searchInfo.state = (address?.administrativeArea)!
            self.searchInfo.zip = (address?.postalCode)!
            self.tableView.reloadData()
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

