//
//  SideMenuViewController.swift
//  UnitedVision
//
//  Created by Agilink on 16/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//


enum LeftMenu: Int {
    case home = 0
//    case login
//    case register
    case tractorSearch
    case terminalSearch
    case contact
    case logout
    case login
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

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupInitialView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupInitialView ()
    {
//        signInButton.isHidden = DataManager.sharedInstance.isLogin ? true : false
       // nameLabel.text = DataManager.sharedInstance.isLogin ? "Welcome Meenakshi" : "Welcome Guest"
        
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
        self.slideMenuController()?.closeLeft()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        if let navCtrl = self.slideMenuController()?.mainViewController as? UINavigationController
        {
            navCtrl.pushViewController(viewCtrl, animated: true)
        }
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
            
        switch menu {
//            case .login:
//                    self.showLoginView()
//                    break;
        case .logout:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logout()
            self.slideMenuController()?.closeLeft()
            break
        case .login:
            signInButtonAction()
        default:
            if let viewCtrl =  self.getViewControllerFor(menu: menu){
                let navCtrl = UINavigationController(rootViewController: viewCtrl)
                self.slideMenuController()?.changeMainViewController(navCtrl, close: true)
            }
            break
            
            
        }
       

    }
    
    func getViewControllerFor(menu: LeftMenu) -> UIViewController? {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch menu {
        case .home:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            return viewCtrl
            
        case .terminalSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalSearchViewController") as! TerminalSearchViewController
            return viewCtrl
            
        case .tractorSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorViewController") as! TractorViewController
            return viewCtrl
            
        case .contact:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
            return viewCtrl
           
        default:
                break
        }
        return nil
    }

    
    func showLoginView()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
//        self.providesPresentationContextTransitionStyle = true
//        self.definesPresentationContext = true
        viewCtrl.modalPresentationStyle = .overCurrentContext

        self.present(viewCtrl, animated: true, completion: nil)
    }
}
