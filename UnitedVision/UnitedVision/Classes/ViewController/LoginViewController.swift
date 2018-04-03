//
//  LoginViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextfield : UITextField!
    @IBOutlet weak var passwordTextfield : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.title = "Login"
        setTitleView(withTitle: "Login", Frame: nil)
        emailTextfield.text = "customer" // ""owner.operator
        passwordTextfield.text = "uvlgo4it"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setNavigationBarItem()
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
}

extension LoginViewController{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
