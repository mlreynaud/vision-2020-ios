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
enum RegUserType: String{
    case Customer = "CU"
    case OwnerDriver = "OD"
    case FleetOwner = "FO"
    case Carrier = "CA"
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
    case ECountry
    case EZip
    case EUserType
    case EPayeeID
    case EDriverID
    case ECusID
    case ECarrierNumType
    case ECarrierNum
    case ECarrierState
    case EDotFid
    case EAgreeToTerms
    case EUserID
    case EPass
    case EConfirmPass
}

class RegisterViewController: UITableViewController, UITextFieldDelegate {
    
    var regCellArr: [Any]?
    var agreeToTerms: Bool = false
    
    @IBOutlet weak var selectedStateLbl: UILabel!
    @IBOutlet weak var selectedCountryLbl: UILabel!
    @IBOutlet weak var selectedUserTypeLbl: UILabel!
    @IBOutlet weak var selectedCarrierNumberTypeLbl: UILabel!
    @IBOutlet weak var selectedCarrierStateLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "Register", Frame: nil)
        fetchRegCellArr()
    }
    
    func setTitleView(withTitle title: String,Frame frame:CGRect?) {
        let titleView = TitleView.loadViewFromNib()
        titleView.setTitle(Title: title, Frame: frame)
        self.navigationItem.titleView = titleView
    }
    
    func fetchRegCellArr() {
        regCellArr?.removeAll()
        let parsedArr = UIUtils.parsePlist(ofName: "RegisterCellInfo") as! [Dictionary<String,Any>]
        regCellArr?.append(parsedArr)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func agreeToTermsPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agreeToTerms = sender.isSelected
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        if checkForTextLength(){
            print("Data entered is correct")
        }
        else {
            UIUtils.showAlert(withTitle: kAppTitle, message: "Some Of the fields have been left emptied or too much data is entered for them.", inContainer: self)
        }
    }
    
    func checkForTextLength() -> Bool{
        let isSuccess = true
        let textFieldArr = fetchTextFields()
        let textValidationArr = UIUtils.parsePlist(ofName:"RegisterCellInfo") as! [Dictionary<String,Any>]
        for textField in textFieldArr{
            let validDict = textValidationArr[textField.tag]
            let maxLength = validDict["maxLength"] as! Int
            if (textField.text?.count)! >= maxLength{
                return false
            }
            if textField.text?.count == 0 && validDict["Required"] as! Bool {
                return false
            }
        }
        return isSuccess
    }
    func fetchTextFields() ->[UITextField]{
        var textFieldArr = [UITextField]()
        for tag in 1...24{
            if let textField = view.viewWithTag(tag) as? UITextField{
                textFieldArr.append(textField)
            }
        }
        return textFieldArr
    }
    
    @IBAction func dropDownPressed(_ sender: UIButton) {
        let tag = sender.tag
        let regDataField = RegDataField(rawValue: tag)
        if regDataField == .EState{
            let stateDict = UIUtils.parsePlist(ofName: "UsStateList") as! Dictionary<String,Any>
            var stateArr = [String]()
            for key in stateDict{
                stateArr.append("\(key)")
            }
            presentRegFieldPickerController(withData: stateArr)
        }
        else if regDataField == .ECountry{
            
        }
        else if regDataField == .EUserType{
            
        }
        else if regDataField == .ECarrierNumType{
            
        }
        else if regDataField == .ECarrierState{
            
        }
    }
    func presentRegFieldPickerController(withData data:[String]){
        let regFieldPicker = RegFieldPickerController.initiateRegFieldPicker()
        regFieldPicker.fieldCompletionHandler = { (selectedStr) in
            if selectedStr != nil {
//                self.performListSortingFor(SortType: selectedSortType!)
            }
        }
        regFieldPicker.modalPresentationStyle = .overCurrentContext
        self.present(regFieldPicker, animated: true, completion: nil)
    }
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
