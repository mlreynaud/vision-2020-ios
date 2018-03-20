//
//  SideMenuViewController.swift
//  UnitedVision
//
//  Created by Agilink on 16/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//


enum LeftMenu: Int {
    case home = 0
    case tractorSearch
    case terminalSearch
    case contact
    case logout
    case login
}
protocol SideMenuLogOutDelegate {
    func sideMenuLogOutPressed()
}

import UIKit

class SideMenuViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var signInButton : UIButton!
    @IBOutlet weak var tableView : UITableView!
    
    var menus: [String] = []
    var imageList : [String] = []
    var menuValues: [LeftMenu] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupInitialView()
    }
    
    func setupInitialView ()
    {        
        self.populateArray()
        if (DataManager.sharedInstance.isLogin){
            let userName = DataManager.sharedInstance.userTypeStr
            nameLabel.text = "Welcome " + userName
            signInButton.isHidden = true
        } else{
            let textString = "Welcome Sign In"
            nameLabel.attributedText = textString.createUnderlineString(subString: "Sign In", underlineColor: UIColor.black)
            signInButton.isHidden = false
        }
    }
    
    func populateArray() {
        
        if (DataManager.sharedInstance.isLogin) {
            menus = ["Home", "Tractor Search", "Terminal Search", "Contact", "Log Out"]
            imageList = ["ic_home","ic_truck_gray", "ic_location_black" ,"ic_call_black", "ic_logout"]
            menuValues = [.home, .tractorSearch, .terminalSearch, .contact, .logout]
        }
        else{
            menus = ["Home", "Terminal Search", "Contact", "Log In"]
            imageList = ["ic_home", "ic_location_black" ,"ic_call_black", "ic_login_red"]
            menuValues = [.home, .terminalSearch, .contact, .login]
        }
        
        tableView.reloadData()
    }
    
    @IBAction func signInButtonAction()
    {
        let index = menus.index(of:"Log In")
        tableView(tableView, didSelectRowAt: IndexPath(item: index!, section: 0))
    }
}

extension SideMenuViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell", for: indexPath) as! SideMenuTableCell
        cell.titleLabel.text = menus[indexPath.row]
        cell.iconImageView.image = UIImage(named: imageList[indexPath.row])
        cell.iconImageView.tintColor = UIColor.gray
        cell.menuValue = menuValues[indexPath.row].rawValue
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menu = menuValues[indexPath.row]
        let navViewCtrl = slideMenuController()?.mainViewController as? UINavigationController
        
        switch menu {
        case .home:
            navViewCtrl?.popToRootViewController(animated: true)
            break
        case .logout:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logout()
            
            if let navViewCtrl = slideMenuController()?.mainViewController as? UINavigationController{
                if let topViewCtrl = navViewCtrl.topViewController{
                    if let sideMenuDelegate = topViewCtrl as? SideMenuLogOutDelegate{
                        sideMenuDelegate.sideMenuLogOutPressed()
                    }
                }
            }
            break
        default:
            let currVC = navViewCtrl?.topViewController
            if let newVC = getViewControllerFor(menu: menu), object_getClassName(currVC) != object_getClassName(newVC){
                navViewCtrl?.popToRootViewController(animated: false)
                navViewCtrl?.pushViewController(newVC, animated: true)
            }
            break
        }
        self.slideMenuController()?.closeLeft()
    }
    
    func getViewControllerFor(menu: LeftMenu) -> UIViewController? {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch menu {
        case .terminalSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalSearchViewController") as! TerminalSearchViewController
            return viewCtrl
            
        case .tractorSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorViewController") as! TractorViewController
            return viewCtrl
            
        case .contact:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
            return viewCtrl
        case .login:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            return viewCtrl
        default:
                break
        }
        return nil
    }
}
