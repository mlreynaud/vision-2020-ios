//
//  LoginViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var emailTextfield : UITextField!
    @IBOutlet weak var passwordTextfield : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Login"
        
        emailTextfield.text = "customer" // ""owner.operator
        passwordTextfield.text = "uvlgo4it"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setNavigationBarItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
//    @IBAction func forgotPasswordButtonAction()
//    {
//        
//    }
//    @IBAction func registerButtonAction()
//    {
//        
//    }
//    
//    @IBAction func closeButtonAction()
//    {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
