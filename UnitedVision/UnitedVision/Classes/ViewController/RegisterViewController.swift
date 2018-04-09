//
//  RegisterViewController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 03/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

enum RegCellType : Int{
    case ENormal = 0
    case EList = 1
    case ECheckBox = 2
    case EPassword = 3
}

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
            return "USState"
        case RegDataField.EUserType:
            return "UserType"
        case RegDataField.ECarrierNumType:
            return "CarrierNumberType"
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
    
    var dataValidationArr: [Dictionary<String,Any>]?
    var usStateDict: Dictionary<String,String>?
    var userTypeDict: Dictionary<String,String>?
    var carrierNumberTypeDict: Dictionary<String,String>?

    @IBOutlet weak var userTypeBtn: UIButton!
    @IBOutlet weak var carrierNumTypeBtn: UIButton!
    @IBOutlet weak var carrierStateBtn: UIButton!
    
    var textFieldArr: [UITextField]?
    
    var agreeToTerms: Bool = false
    
    var selectedState: String?
    var selectedUserType: String?
    var selectedCarrierNumberType: String?
    var selectedCarrierState: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "Register", Frame: nil)
        fetchDataFromPlists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchTextFields()
        reloadTextFieldsBackground()
        reloadDropDownBtns()
    }
    
    func setTitleView(withTitle title: String,Frame frame:CGRect?) {
        let titleView = TitleView.loadViewFromNib()
        titleView.setTitle(Title: title, Frame: frame)
        self.navigationItem.titleView = titleView
    }
    
    func fetchDataFromPlists() {
        dataValidationArr = UIUtils.parsePlist(ofName: "RegisterCellInfo") as? [Dictionary<String, Any>]
        usStateDict = UIUtils.parsePlist(ofName: "USState") as? Dictionary<String, String>
        userTypeDict = UIUtils.parsePlist(ofName: "UserType") as? Dictionary<String, String>
        carrierNumberTypeDict = UIUtils.parsePlist(ofName: "CarrierNumberType") as? Dictionary<String, String>
    }
    
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 12{
            return nil
        }
        return indexPath
    }
    
    @IBAction func agreeToTermsPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agreeToTerms = sender.isSelected
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        if checkForTextLength(){
            if !(selectedCarrierNumberType == "" || selectedState == "" || selectedUserType == "" || selectedCarrierState == ""){
                UIUtils.showAlert(withTitle: kAppTitle, message: "Some Of the fields have been left emptied", inContainer: self)
                return
            }
            
            if !agreeToTerms {
                UIUtils.showAlert(withTitle: kAppTitle, message: "I Agree to Terms not selected", inContainer: self)
                return
            }
            
            if !(emailField.text?.isValidEmail)!{
                UIUtils.showAlert(withTitle: kAppTitle, message: "Incorrect Email Format", inContainer: self)
                return
            }
            
            let passWordField =  textFieldArr?.last
            let confirmPassWordField = textFieldArr![(textFieldArr?.count)! - 2]
            if passWordField?.text != confirmPassWordField.text
            {
                UIUtils.showAlert(withTitle: kAppTitle, message: "Passwords don't match", inContainer: self)
                return
            }
            // Hit API
        }
        else {
            UIUtils.showAlert(withTitle: kAppTitle, message: "Some Of the fields have been left emptied", inContainer: self)
        }
    }
    
    func checkForTextLength() -> Bool {
        let isSuccess = true
        for textField in textFieldArr!{
            let validDict = dataValidationArr![textField.tag]
            let maxLength = validDict["maxLength"] as! Int
            if (textField.text?.count)! == 0 || (textField.text?.count)! >= maxLength{
                return false
            }
        }
        return isSuccess
    }
    
    func fetchTextFields() {
        textFieldArr = [UITextField]()
        for tag in 1...22{
            if let textField = view.viewWithTag(tag) as? UITextField{
                textFieldArr?.append(textField)
            }
        }
    }
    
    func reloadTextFieldsBackground() {
        for textField in textFieldArr!{
            _ = textFieldShouldBeginEditing(textField)
        }
    }
    
    func reloadDropDownBtns() {
        carrierNumTypeBtn.isUserInteractionEnabled = selectedUserType != userTypeDict!["Carrier"] ? false : true
        carrierNumTypeBtn.backgroundColor = selectedUserType != userTypeDict!["Carrier"] ? UIColor.lightGray : UIColor.clear
        carrierStateBtn.isUserInteractionEnabled = selectedCarrierNumberType != carrierNumberTypeDict!["Intrastate"] ? false : true
        carrierStateBtn.backgroundColor = selectedCarrierNumberType != carrierNumberTypeDict!["Intrastate"] ? UIColor.lightGray : UIColor.clear
    }
    
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
        let regFieldPicker = RegFieldPickerController.initiateRegFieldPicker()
        regFieldPicker.dataList = data
        regFieldPicker.fieldCompletionHandler = { (selectedStr) in
            if selectedStr != nil {
                if regDataField == .EState{
                    self.selectedStateLbl.text = selectedStr
                    self.selectedState = self.usStateDict![selectedStr!]
                }
                else if regDataField == .EUserType{
                    self.selectedUserTypeLbl.text = selectedStr
                    self.selectedUserType = self.userTypeDict![selectedStr!]
                }
                else if regDataField == .ECarrierNumType{
                    self.selectedCarrierNumberTypeLbl.text = selectedStr
                    self.selectedCarrierNumberType = self.carrierNumberTypeDict![selectedStr!]
                }
                else if regDataField == .ECarrierState{
                    self.selectedCarrierStateLbl.text = selectedStr
                    self.selectedCarrierState = self.usStateDict![selectedStr!]
                }
                self.reloadTextFieldsBackground()
                self.reloadDropDownBtns()
            }
        }
        regFieldPicker.modalPresentationStyle = .overCurrentContext
        self.present(regFieldPicker, animated: true, completion: nil)
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var should: Bool = true
        let tag = textField.tag
        let regDataField = RegDataField(rawValue: tag)
        if regDataField == .EPayeeID && selectedUserType == userTypeDict!["Customer"] {
            should = false
        }
        else if regDataField == .EDriverID && selectedUserType != userTypeDict!["Owner\\Driver"]{
            should = false
        }
        else if regDataField == .ECusID && selectedUserType != userTypeDict!["Customer"]{
            should = false
        }
        else if (regDataField == .ECarrierNum || regDataField == .EDotFid) && selectedUserType != userTypeDict!["Carrier"]{
            should = false
        }
        else if regDataField == .ECarrierState && selectedCarrierState != carrierNumberTypeDict!["Intrastate"]{
            should = false
        }
        textField.backgroundColor = should ? UIColor.white : UIColor.lightGray
        return should
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
