//
//  LoginViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import MessageUI

let kHeightOfOtherRows = CGFloat(422)
let kDefaultHeightOfEmptyRow = CGFloat(44)
let kEmptyRowIndex = 5
let kForgotPassPhNo = "8002703158"
let kForgotPassEmail = "uvlwebsitesupport@uvlogistics.com"

class LoginViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var emailTextfield : UITextField!
    @IBOutlet weak var passwordTextfield : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "LOGIN", Frame: nil)
        emailTextfield.text = "" // ""owner.operator
        passwordTextfield.text = ""
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.topViewController?.isKind(of: LoginViewController.self) )!
        {
            self.setNavigationBarItem()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Button Action
    @IBAction func loginButtonAction()
    {
        guard let username = emailTextfield.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordTextfield.text?.trimmingCharacters(in: .whitespaces),
            username.count > 0, password.count > 0
            else {

                UIUtils.showAlert(withTitle: kAppTitle, message: "Please enter a valid useranme or password.", inContainer: self)
                return
        }
        LoadingView.shared.showOverlay()
        DataManager.sharedInstance.request(toLogin: username, withPassword: password, completionHandler: {(status, errorMessage) in
            
            LoadingView.shared.hideOverlayView()
            
            if (status)
            {
                DataManager.sharedInstance.userName = username
                DataManager.sharedInstance.isLogin = true
                AppPrefData.sharedInstance.isLogin = true
                AppPrefData.sharedInstance.saveAllData()
                
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                UIUtils.showAlert(withTitle: kAppTitle, message: errorMessage, inContainer: self)
            }
        })
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController")
        self.navigationController?.pushViewController(registerVC!, animated: true)
    }
    
    @IBAction func callBtnPressed(_ sender: Any) {
        UIUtils.callPhoneNumber(kForgotPassPhNo)
    }
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        UIUtils.presentMailComposeVC(email:kForgotPassEmail, presentingVC: self)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == kEmptyRowIndex{
            let emptyRowHeight = tableView.frame.height - kHeightOfOtherRows
            return max(emptyRowHeight,kDefaultHeightOfEmptyRow)
        }
        else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

extension LoginViewController{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
