//
//  RegisterViewController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 03/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

let kRegDataValidpList = "RegDataValidation"
let kUsStatepList = "USState"

let kRegFieldStateTitle = "State"
let KRegFieldUserTypeTitle = "User Type"
let KRegFieldCarrierNumTypeTitle = "Carrier Num Type"
let KRegFieldCarrierStateTitle = "State"

let kRegThankMess = "Thank you for submitting your registration request. The registration typically takes no more than 48 hours to process. We will send you an email once your registration is approved."

let kRegSuccessMess = "Successful Registration"

enum RegUserType: String {
    case customer = "Customer"
    case ownerDriver = "Owner Operator/Driver"
    case fleetOwner = "Fleet Owner"
    case carrier = "Carrier"
    
    public var identifier: String? {
        switch self {
        case .customer:
            return "CU"
        case .ownerDriver:
            return "OD"
        case .fleetOwner:
            return "FO"
        case .carrier:
            return "CA"
        }
    }
    
    static var array: [String] {
        var arr: [String] = []
        switch RegUserType.customer {
        case .customer: arr.append(RegUserType.customer.rawValue); fallthrough
        case .ownerDriver: arr.append(RegUserType.ownerDriver.rawValue); fallthrough
        case .fleetOwner: arr.append(RegUserType.fleetOwner.rawValue); fallthrough
        case .carrier: arr.append(RegUserType.carrier.rawValue);
        }
        return arr
    }
}

enum RegCarrierNumType: String {
    case mc = "MC"
    case intrastate = "Intrastate"
    
    public var identifier: String? {
        switch self {
        case .mc:
            return "MC"
        case .intrastate:
            return "IN"
        }
    }
    
    static var array: [String] {
        var arr: [String] = []
        switch RegCarrierNumType.mc {
        case .mc: arr.append(RegCarrierNumType.mc.rawValue); fallthrough
        case .intrastate: arr.append(RegCarrierNumType.intrastate.rawValue);
        }
        return arr
    }
}

enum RegDataField: Int{
    case EFirstName = 101
    case ELastName
    case EMail
    case ECompanyName
    case EJobTitle
    case EPhone
    case EAddress1
    case EAddress2
    case ECity
    case EState
    case EZip
    case EUserID
    case EUserType
    case EPass
    case EConfirmPass
    case ECusID
    case EOwnerDriverPayeeID
    case EDriverID
    case EFleetOwnerPayeeID
    case ECarrierNumType
    case ECarrierNum
    case EDotFid
    case ECarrierState
    
    static func regFieldPickerTitleHeader(regDataField:RegDataField) -> String? {
        switch regDataField {
        case RegDataField.EState:
            return kRegFieldStateTitle
        case RegDataField.EUserType:
            return KRegFieldUserTypeTitle
        case RegDataField.ECarrierNumType:
            return KRegFieldCarrierNumTypeTitle
        case RegDataField.ECarrierState:
            return KRegFieldCarrierStateTitle
        default:
            return nil
        }
    }
}

enum RegError :Error{
    case EEmptyFields
    case EAgreeToTerms
    case EInvalidEmail
    case EPassNotMatch
    case EInvalidPass
}
extension RegError : LocalizedError{
    public var errorDescription: String? {
        switch self {
        case .EEmptyFields:
            return "Some Of the fields have been left emptied."
        case .EAgreeToTerms:
            return "You must agree to the terms before registering."
        case .EInvalidEmail:
            return "Incorrect Email Format."
        case .EPassNotMatch:
            return "Passwords don't match."
        case .EInvalidPass:
            return "Password should contain at least 6 chars, with at least 1 upper case and 1 number."
        }
    }
}

let kFieldTagOverhead = 101
let kNumOfFields = 22

class RegisterViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var carrierTypeCell: UITableViewCell!
    @IBOutlet var ownerDriverCell: UITableViewCell!
    @IBOutlet var fleetOwnerCell: UITableViewCell!
    @IBOutlet var customerTypeCell: UITableViewCell!
    
    var dataValidationArr: [Dictionary<String,Any>]?
    var usStateDict: Dictionary<String,String>?

    @IBOutlet var textFields: [UITextField]!

    var agreeToTerms: Bool = false
    var selectedState = String()
    var selectedUserType: RegUserType?
    var selectedCarrierNumberType: RegCarrierNumType?
    var selectedCarrierState = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "REGISTER", Frame: nil)
        tableView.separatorStyle = .none
        fetchDataFromPlists()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTextFieldDelegate()
    }
    
    func fetchDataFromPlists() {
        dataValidationArr = UIUtils.parsePlist(ofName: kRegDataValidpList) as? [Dictionary<String, Any>]
        usStateDict = UIUtils.parsePlist(ofName: kUsStatepList) as? Dictionary<String, String>
    }
    
    func setTextFieldDelegate(){
        for textField in textFields{
            textField.delegate = self
        }
    }
    
    func returnFieldCell(regUserType: RegUserType) -> UITableViewCell {
        switch regUserType {
        case .customer:
            return customerTypeCell
        case .ownerDriver:
            return ownerDriverCell
        case .fleetOwner:
            return fleetOwnerCell
        case .carrier:
            return carrierTypeCell
        }
    }
    
    func returnIndexPathFor(regCarrierNumType: RegCarrierNumType) -> IndexPath {
        switch regCarrierNumType {
        case .mc:
            return IndexPath(row: 14, section: 0)
        case .intrastate:
            return IndexPath(row: 15, section: 0)
        }
    }
    func returnIndexPathFor(regUserType: RegUserType) -> IndexPath {
        switch regUserType {
        case .customer:
            return IndexPath(row: 10, section: 0)
        case .ownerDriver:
            return IndexPath(row: 11, section: 0)
        case .fleetOwner:
            return IndexPath(row: 12, section: 0)
        case .carrier:
            return IndexPath(row: 13, section: 0)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension RegisterViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if section == 0{
            if selectedUserType != nil{
                numberOfRows = 11
                if selectedCarrierNumberType != nil{
                    numberOfRows = 12
                }
            }
            numberOfRows = numberOfRows == 0 ? 10 : numberOfRows
        }
        else {
            numberOfRows = 2
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0{
            if selectedUserType != nil{
                if indexPath.row == 10 {
                    cell = super.tableView(tableView, cellForRowAt: returnIndexPathFor(regUserType: selectedUserType!))
                }
                if indexPath.row == 11 {
                    cell = super.tableView(tableView, cellForRowAt: returnIndexPathFor(regCarrierNumType: selectedCarrierNumberType!))
                }
            }
        }
        cell = cell ?? super.tableView(tableView, cellForRowAt: indexPath)
        cell?.selectionStyle = .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RegisterViewController{

    @IBAction func agreeToTermsPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agreeToTerms = sender.isSelected
    }

    @IBAction func registerBtnPressed(_ sender: Any) {
        do{
            try checkForTextLength()
            try checkEmailValidation()
            try checkPasswordMatch()
            try checkPasswordFormat()
            try checkTermsAgreement()
        }
        catch{
            UIUtils.showAlert(withTitle: kAppTitle, message: (error as! RegError).errorDescription!, inContainer: self)
            return
        }
        performRegistration()
    }
    
    func checkEmailValidation() throws{
        let emailField = textFields[RegDataField.EMail.rawValue - kFieldTagOverhead]
        if !(emailField.text?.isValidEmail)!{
            throw RegError.EInvalidEmail
        }
    }
    
    func checkPasswordMatch() throws{
        let passwordField = textFields[RegDataField.EPass.rawValue - kFieldTagOverhead]
        let confirmpasswordField = textFields[RegDataField.EConfirmPass.rawValue - kFieldTagOverhead]
        if passwordField.text != confirmpasswordField.text{
            throw RegError.EPassNotMatch
        }
    }
    
    func checkPasswordFormat() throws{
        let passwordField = textFields[RegDataField.EPass.rawValue - kFieldTagOverhead]
        if !(passwordField.text?.isValidPass)!{
            throw RegError.EInvalidPass
        }
    }
    
    func checkTermsAgreement() throws{
        if !agreeToTerms{
            throw RegError.EAgreeToTerms
        }
    }

    func checkForTextLength() throws {
        
        for i in (0...14){
            let textField = textFields[i]
            if (i != 7 && i <= 14 && (textField.text?.isBlank())!) {
                throw RegError.EEmptyFields
            }
        }
        
        if selectedUserType == RegUserType.customer{
            let custIdField = textFields[RegDataField.ECusID.rawValue - kFieldTagOverhead]
            if (custIdField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        if selectedUserType == RegUserType.ownerDriver{
            let payeeIDField = textFields[RegDataField.EOwnerDriverPayeeID.rawValue - kFieldTagOverhead]
            if (payeeIDField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
            let driverIdField = textFields[RegDataField.EOwnerDriverPayeeID.rawValue - kFieldTagOverhead]
            if (driverIdField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        if selectedUserType == RegUserType.fleetOwner{
            let payeeIDField = textFields[RegDataField.EFleetOwnerPayeeID.rawValue - kFieldTagOverhead]
            if (payeeIDField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        if selectedUserType == RegUserType.carrier{
            let carrierNumTypeField = textFields[RegDataField.ECarrierNumType.rawValue - kFieldTagOverhead]
            if (carrierNumTypeField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
            let carrierNumField = textFields[RegDataField.ECarrierNum.rawValue - kFieldTagOverhead]
            if (carrierNumField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
            
        }
        if selectedCarrierNumberType == RegCarrierNumType.mc{
            let dotOrFidField = textFields[RegDataField.EDotFid.rawValue - kFieldTagOverhead]
            if (dotOrFidField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        else if selectedCarrierNumberType == RegCarrierNumType.intrastate{
            let carrierStateField = textFields[RegDataField.ECarrierState.rawValue - kFieldTagOverhead]
            if (carrierStateField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
    }

    func performRegistration(){
        let paramDict = createParamDict()
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.performRegistrationWith(paramDict: paramDict) { (status, str, error) in
            LoadingView.shared.hideOverlayView()
            var messageStr = error?.localizedDescription ?? kNetworkErrorMessage
            if str == "Pending"{
                messageStr = kRegThankMess
            }
            else if str == "Carrier"{
                messageStr = kRegSuccessMess
            }
            UIUtils.showAlert(withTitle: kAppTitle, message: messageStr, inContainer: self, completionCallbackHandler: {
                if status{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    fileprivate func addFieldDataToParamDict(_ fieldIndex: Int, _ paramDict: inout [String : Any]) {
        let textField = textFields[fieldIndex]
        let fieldValidDict = dataValidationArr![fieldIndex]
        let key = fieldValidDict["paramKey"] as! String
        paramDict[key] = textField.text
    }
    
    func createParamDict() -> Dictionary<String,Any>{
        var paramDict = Dictionary<String, Any>()
        for fieldIndex in (0...(kNumOfFields - 2)){
            addFieldDataToParamDict(fieldIndex, &paramDict)
        }
        if selectedCarrierNumberType == RegCarrierNumType.mc{
            addFieldDataToParamDict(RegDataField.EDotFid.rawValue - kFieldTagOverhead, &paramDict)
        }
        else if selectedCarrierNumberType == RegCarrierNumType.intrastate{
            addFieldDataToParamDict(RegDataField.ECarrierState.rawValue - kFieldTagOverhead, &paramDict)
        }
        paramDict["agreeToTerms"] = agreeToTerms ? "Y" : "N"
        return paramDict
    }
    
}
extension RegisterViewController{

    @IBAction func dropDownPressed(_ sender: UIButton) {
        let tag = sender.tag
        let regDataField = RegDataField(rawValue: tag)
        var dropDownDataArr = [String]()

        if regDataField == .EState || regDataField == .ECarrierState {
            let pListName = kUsStatepList
            let dropDownDataDict = UIUtils.parsePlist(ofName:pListName) as! Dictionary<String,Any>
            for (key,_) in dropDownDataDict{
                dropDownDataArr.append("\(key)")
            }
            dropDownDataArr = dropDownDataArr.sorted(by: {$0 < $1})
        }
        else if regDataField == .EUserType{
            dropDownDataArr = RegUserType.array
        }
        else if regDataField == .ECarrierNumType {
            dropDownDataArr = RegCarrierNumType.array
        }
        if dropDownDataArr.count > 0{
            presentRegFieldPickerController(withData: dropDownDataArr,for: regDataField!)
        }
    }

    func presentRegFieldPickerController(withData data:[String], for regDataField: RegDataField){
        let popOverVC = PopOverViewController.initiatePopOverVC()
        popOverVC.titleText = RegDataField.regFieldPickerTitleHeader(regDataField: regDataField) ?? ""
        popOverVC.dataList = data
        popOverVC.popOverCompletionHandler = { (selectedOption) in
            if selectedOption != nil {
                let selectedStr = data[selectedOption!]
                if regDataField == .EState{
                    let selectedField = self.textFields[RegDataField.EState.rawValue - kFieldTagOverhead]
                    selectedField.text = selectedStr
                    self.selectedState = self.usStateDict![selectedStr]!
                }
                else if regDataField == .EUserType{
                    let selectedField = self.textFields[RegDataField.EUserType.rawValue - kFieldTagOverhead]
                    selectedField.text = selectedStr
                    self.selectedUserType = RegUserType(rawValue: selectedStr)
                }
                else if regDataField == .ECarrierNumType{
                    let selectedField = self.textFields[regDataField.rawValue - kFieldTagOverhead]
                    selectedField.text = selectedStr
                    self.selectedCarrierNumberType = RegCarrierNumType(rawValue:selectedStr)
                }
                else if regDataField == .ECarrierState{
                    let selectedField = self.textFields[regDataField.rawValue - kFieldTagOverhead]
                    selectedField.text = selectedStr
                    self.selectedCarrierState = self.usStateDict![selectedStr]!
                }
                self.tableView.reloadData()
                self.view.endEditing(true)
            }
        }
        popOverVC.modalTransitionStyle = .crossDissolve
        popOverVC.modalPresentationStyle = .overCurrentContext
        self.present(popOverVC, animated: true, completion: nil)
    }
}




