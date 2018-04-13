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
let kUserTypepList = "UserType"
let kCarrierNumTypepList = "CarrierNumberType"

let kMaxLengthKey = "maxLength"

let kCustomerKey = "Customer"
let kIntrastateKey = "Intrastate"
let kCarrierKey = "Carrier"
let kOwnerDriverKey = "Owner\\Driver"


let kRegFieldStateTitle = "State"
let KRegFieldUserTypeTitle = "User Type"
let KRegFieldCarrierNumTypeTitle = "Carrier Num Type"
let KRegFieldCarrierStateTitle = "State"

enum RegDataField: Int{
    case EFirstName = 1
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
    case EUserType
    case EPayeeID
    case EDriverID
    case ECusID
    case ECarrierNumType
    case ECarrierNum
    case ECarrierState
    case EDotFid
    case EUserID
    case EPass
    case EConfirmPass
    
    static func pListName(regDataField:RegDataField) -> String? {
        switch regDataField {
        case RegDataField.EState, RegDataField.ECarrierState:
            return kUsStatepList
        case RegDataField.EUserType:
            return kUserTypepList
        case RegDataField.ECarrierNumType:
            return kCarrierNumTypepList
        default:
            return nil
        }
    }
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

class RegisterViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var selectedStateLbl: UILabel!
    @IBOutlet weak var selectedUserTypeLbl: UILabel!
    @IBOutlet weak var selectedCarrierNumberTypeLbl: UILabel!
    @IBOutlet weak var selectedCarrierStateLbl: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    var dataValidationArr: [Dictionary<String,Any>]?
    var usStateDict: Dictionary<String,String>?
    var userTypeDict: Dictionary<String,String>?
    var carrierNumberTypeDict: Dictionary<String,String>?

    @IBOutlet weak var userTypeBtn: UIButton!
    @IBOutlet weak var carrierNumTypeBtn: UIButton!
    @IBOutlet weak var carrierStateBtn: UIButton!
    
    @IBOutlet var textFields: [UITextField]!
    
    var agreeToTerms: Bool = false
    
    var selectedState = String()
    var selectedUserType = String()
    var selectedCarrierNumberType = String()
    var selectedCarrierState = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "REGISTER", Frame: nil)
        tableView.separatorStyle = .none
        fetchDataFromPlists()
        reloadTextFieldsBackground()
        reloadDropDownBtns()
    }
    
    func fetchDataFromPlists() {
        dataValidationArr = UIUtils.parsePlist(ofName: kRegDataValidpList) as? [Dictionary<String, Any>]
        usStateDict = UIUtils.parsePlist(ofName: kUsStatepList) as? Dictionary<String, String>
        userTypeDict = UIUtils.parsePlist(ofName: kUserTypepList) as? Dictionary<String, String>
        carrierNumberTypeDict = UIUtils.parsePlist(ofName: kCarrierNumTypepList) as? Dictionary<String, String>
    }
    
    func reloadTextFieldsBackground() {
        for textField in textFields!{
            _ = textFieldShouldBeginEditing(textField)
        }
    }
    
    func reloadDropDownBtns() {
        carrierNumTypeBtn.isUserInteractionEnabled = selectedUserType != userTypeDict![kCarrierKey] ? false : true
        carrierNumTypeBtn.backgroundColor = selectedUserType != userTypeDict![kCarrierKey] ? UIColor.lightGray : UIColor.clear
        carrierStateBtn.isUserInteractionEnabled = selectedCarrierNumberType != carrierNumberTypeDict![kIntrastateKey] ? false : true
        carrierStateBtn.backgroundColor = selectedCarrierNumberType != carrierNumberTypeDict![kIntrastateKey] ? UIColor.lightGray : UIColor.clear
    }
    
}
extension RegisterViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

enum RegError :Error{
    case EEmptyFields
    case EAgreeToTerms
    case EInvalidEmail
    case EInvalidPass
}
extension RegError : LocalizedError{
    public var errorDescription: String? {
        switch self {
        case .EEmptyFields:
            return "Some Of the fields have been left emptied"
        case .EAgreeToTerms:
            return "I Agree to Terms not selected"
        case .EInvalidEmail:
            return "Incorrect Email Format"
        case .EInvalidPass:
            return "Passwords don't match"
        }
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
            if !(emailField.text?.isValidEmail)!{
                throw RegError.EInvalidEmail
            }
            if passwordField?.text != confirmPassField.text{
                throw RegError.EInvalidPass
            }
            if !agreeToTerms{
                throw RegError.EAgreeToTerms
            }
        }
        catch{
            UIUtils.showAlert(withTitle: kAppTitle, message: (error as! RegError).errorDescription!, inContainer: self)
            return
        }
        performRegistration()
    }
    
    func checkForTextLength() throws {
        for i in 1...7{
            let textField = textFields[i]
            if (textField.text?.isBlank())! {
                throw RegError.EEmptyFields
            }
        }
        
        if selectedState.isBlank() {
            throw RegError.EEmptyFields
        }
        
        let cityTextField = textFields[9]
        if (cityTextField.text?.isBlank())!{
            throw RegError.EEmptyFields
        }
        
        if selectedUserType.isBlank(){
            throw RegError.EEmptyFields
        }
        
        let isPayeeIdReq = selectedUserType != userTypeDict![kCustomerKey]
        if isPayeeIdReq, let payeeIdField = UIUtils.returnElement(with: RegDataField.EPayeeID.rawValue, from: textFields) as? UITextField{
            if (payeeIdField.text?.isBlank())! {
                throw RegError.EEmptyFields
            }
        }
        
        let isDriverIdReq = selectedUserType == userTypeDict![kOwnerDriverKey]
        if isDriverIdReq, let driverIdField = UIUtils.returnElement(with: RegDataField.EDriverID.rawValue, from: textFields) as? UITextField{
            if (driverIdField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        let isCustIdReq = selectedUserType == userTypeDict![kCustomerKey]
        if isCustIdReq, let custIdField = UIUtils.returnElement(with: RegDataField.ECusID.rawValue, from: textFields) as? UITextField{
            if (custIdField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        let isCarrierNumTypeReq = selectedUserType == userTypeDict![kCarrierKey]
        if isCarrierNumTypeReq, selectedCarrierNumberType.isBlank(){
            throw RegError.EEmptyFields
        }
        
        let isCarrierNumReq = selectedUserType == userTypeDict![kCarrierKey]
        if isCarrierNumReq, let carrierNumField = UIUtils.returnElement(with: RegDataField.ECarrierNum.rawValue, from: textFields) as? UITextField{
            if (carrierNumField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        let isCarrierStateReq = selectedCarrierNumberType == carrierNumberTypeDict![kIntrastateKey]
        if isCarrierStateReq, selectedCarrierState.isBlank() {
            throw RegError.EEmptyFields
        }
        
        let dotOrFidReq = selectedUserType == userTypeDict![kCarrierKey]
        if dotOrFidReq, let dotOrFidField = UIUtils.returnElement(with: RegDataField.EDotFid.rawValue, from: textFields) as? UITextField{
            if (dotOrFidField.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
        
        for textFieldTag in (RegDataField.EUserID.rawValue...RegDataField.EConfirmPass.rawValue){
            let textField = UIUtils.returnElement(with: textFieldTag, from: textFields) as? UITextField
            if (textField?.text?.isBlank())!{
                throw RegError.EEmptyFields
            }
        }
    }
    
    func performRegistration(){
        let paramDict = createParamDict()
        DataManager.sharedInstance.performRegistrationWith(paramDict: paramDict) { (status, str, error) in
            let messageStr = str ?? error?.localizedDescription ?? kNetworkErrorMessage
                UIUtils.showAlert(withTitle: kAppTitle, message: messageStr, inContainer: self, completionCallbackHandler: {
                    if status{
                        self.navigationController?.popViewController(animated: true)
                    }
                })
        }
    }
    func createParamDict() -> Dictionary<String,Any>{
        var paramDict = Dictionary<String, Any>()
        for fieldIndex in (1...22){
            let regFieldType = RegDataField(rawValue: fieldIndex)!
            switch regFieldType{
            case .EState:
                paramDict["state"] = selectedState
            case .EUserType:
                paramDict["userType"] = selectedUserType
            case .ECarrierNumType:
                paramDict["carrierNumberType"] = selectedCarrierNumberType
            case .ECarrierState:
                paramDict["carrierState"] = selectedCarrierState
            default:
                let textField = UIUtils.returnElement(with: fieldIndex, from: textFields) as! UITextField
                let fieldValidDict = dataValidationArr![fieldIndex-1]
                let key = fieldValidDict["paramKey"] as! String
                paramDict[key] = textField.text
            }
        }
        paramDict["agreeToTerms"] = agreeToTerms ? "Y" : "N"
        return paramDict
    }
}
extension RegisterViewController{
    
    @IBAction func dropDownPressed(_ sender: UIButton) {
        let tag = sender.tag
        let regDataField = RegDataField(rawValue: tag)
        
        if regDataField == .EState || regDataField == .EUserType || regDataField == .ECarrierNumType || regDataField == .ECarrierState{
            if let pListName = RegDataField.pListName(regDataField: regDataField!){
                let dropDownDataDict = UIUtils.parsePlist(ofName:pListName) as! Dictionary<String,Any>
                var dropDownDataArr = [String]()
                for (key,_) in dropDownDataDict{
                    dropDownDataArr.append("\(key)")
                }
                dropDownDataArr = dropDownDataArr.sorted(by: {$0 < $1})
                presentRegFieldPickerController(withData: dropDownDataArr,for: regDataField!)
            }
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
                    self.selectedStateLbl.text = selectedStr
                    self.selectedState = self.usStateDict![selectedStr]!
                }
                else if regDataField == .EUserType{
                    self.selectedUserTypeLbl.text = selectedStr
                    self.selectedUserType = self.userTypeDict![selectedStr]!
                }
                else if regDataField == .ECarrierNumType{
                    self.selectedCarrierNumberTypeLbl.text = selectedStr
                    self.selectedCarrierNumberType = self.carrierNumberTypeDict![selectedStr]!
                }
                else if regDataField == .ECarrierState{
                    self.selectedCarrierStateLbl.text = selectedStr
                    self.selectedCarrierState = self.usStateDict![selectedStr]!
                }
                self.reloadTextFieldsBackground()
                self.reloadDropDownBtns()
                self.view.endEditing(true)
            }
        }
        popOverVC.modalTransitionStyle = .crossDissolve
        popOverVC.modalPresentationStyle = .overCurrentContext
        self.present(popOverVC, animated: true, completion: nil)
    }
}

extension RegisterViewController{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var shouldBeginEdit = false
        shouldBeginEdit = isTextFieldRequired(textField: textField)
        return shouldBeginEdit
    }
    func isTextFieldRequired(textField: UITextField) -> Bool{
        var isRequired: Bool = true
        let tag = textField.tag
        let regDataField : RegDataField = RegDataField(rawValue: tag)!
        switch regDataField {
        case .EPayeeID:
            isRequired = selectedUserType != userTypeDict![kCustomerKey]
        case .EDriverID:
            isRequired = selectedUserType == userTypeDict![kOwnerDriverKey]
        case .ECusID:
            isRequired = selectedUserType == userTypeDict![kCustomerKey]
        case .ECarrierNum, .EDotFid:
            isRequired = selectedUserType == userTypeDict![kCarrierKey]
        case .ECarrierState:
            isRequired = selectedCarrierState == carrierNumberTypeDict![kIntrastateKey]
        default:
            break
        }
        textField.backgroundColor = isRequired ? UIColor.white : UIColor.lightGray
        return isRequired
    }
}



