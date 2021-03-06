//
//  SideMenuViewController.swift
//  UnitedVision
//
//  Created by Agilink on 16/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//
import UIKit

enum LeftMenuItem: RawRepresentable {
    
    case home
    case tractorSearch
    case terminalSearch
    case contact
    case logout
    case login
    case loadBoard
    
    typealias RawValue = UIViewController.Type
    
    init?(rawValue: UIViewController.Type) {
        if rawValue == HomeViewController.self{
            self = .home
        }else if rawValue == TerminalSearchViewController.self {
            self = .terminalSearch
        } else if rawValue == TractorViewController.self {
            self = .tractorSearch
        } else if rawValue == ContactViewController.self {
            self = .contact
        } else if rawValue == LoginViewController.self {
            self = .login
        } else if rawValue == LoadBoardViewController.self {
            self = .loadBoard
        }
        else {
            return nil
        }
    }
    
    var rawValue: UIViewController.Type {
        switch self {
        case .home, .logout:
            return HomeViewController.self
        case .tractorSearch:
            return TractorViewController.self
        case .terminalSearch:
            return TerminalSearchViewController.self
        case .contact:
            return ContactViewController.self
        case .login:
            return LoginViewController.self
        case .loadBoard:
            return LoadBoardViewController.self
        }
    }
    
    public var identifier: String? {
        switch self {
        case .tractorSearch:
            return "TractorViewController"
        case .terminalSearch:
            return "TerminalSearchViewController"
        case .contact:
            return "ContactViewController"
        case .login:
            return "LoginViewController"
        case .loadBoard:
            return "LoadBoardViewController"
        default:
            return nil
        }
    }
    
    public var titleText: String? {
        switch self {
        case .home:
            return "Home"
        case .tractorSearch:
            return "Tractor Search"
        case .terminalSearch:
            return "Terminal Search"
        case .contact:
            return "Contact"
        case .login:
            return "Log In"
        case .logout:
            return "Log Out"
        case .loadBoard:
            return "Load Board"
        }
    }

    public var selectImage: String? {
        switch self {
        case .home:
            return "ic_home_white"
        case .tractorSearch:
            return "ic_truck_white"
        case .terminalSearch:
            return "ic_location_white"
        case .contact:
            return "ic_call_white_hollow"
        case .login:
            return "ic_login_white"
        case .logout:
            return "ic_logout"
        case .loadBoard:
            return "loadBoardWhite"
        }
    }
    
    public var unSelectImage: String? {
        switch self {
        case .home:
            return "ic_home_grey"
        case .tractorSearch:
            return "ic_truck_gray"
        case .terminalSearch:
            return "ic_location_grey"
        case .contact:
            return "ic_call_black"
        case .login:
            return "ic_login_grey"
        case .logout:
            return "ic_logout"
        case .loadBoard:
            return "loadBoardBlack"
        }
    }
    
    public var bottomBtnTitleText: String? {
        switch self {
        case .tractorSearch:
            return "TRACTOR SEARCH"
        case .terminalSearch:
            return "TERMINAL SEARCH"
        case .login:
            return "LOGIN"
        case .loadBoard:
            return "LOAD BOARD"
        case .contact:
            return "CONTACT US"
        default:
            return ""
        }
    }
    
    public var bottomBtnImageName: String {
        switch self {
        case .tractorSearch:
            return "ic_truck_red"
        case .terminalSearch:
            return "ic_location_red"
        case .login:
            return "ic_login_red"
        case .loadBoard:
            return "loadBoardRed"
        case .contact:
            return "ic_call_red"
        default:
            return ""
        }
    }
}

protocol SideMenuLogOutDelegate {
    func sideMenuLogOutPressed()
}

class SideMenuViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView : UITableView!
    
    var menuValues: [LeftMenuItem] = []
    var selectedLeftMenuItem: LeftMenuItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedLeftMenuItem = returnSelectedLeftMenuItem()
        self.populateArray()
        self.tableView.reloadData()
    }
    
    func returnSelectedLeftMenuItem() -> LeftMenuItem?{
        var selectedMenu: LeftMenuItem?
        if let navViewCtrl = slideMenuController()?.mainViewController as? UINavigationController{
            if let topViewCtrl = navViewCtrl.topViewController{
                selectedMenu = LeftMenuItem(rawValue: type(of: topViewCtrl.self))
            }
        }
        return selectedMenu
    }
    
    func populateArray() {
        
        menuValues = [.home, .terminalSearch, .tractorSearch, .loadBoard, .contact, .login, .logout]

        if (DataManager.sharedInstance.isLogin) {
            if let indexOfLogin = menuValues.index(of: .login){
                menuValues.remove(at: indexOfLogin)
            }
        }
        else{
            if let indexOfLogOut = menuValues.index(of: .logout){
                menuValues.remove(at: indexOfLogOut)
            }
        }
        
        if !DataManager.sharedInstance.canAccessTractorSearch{
            if let indexOfTractorSearch = menuValues.index(of: .tractorSearch){
                menuValues.remove(at: indexOfTractorSearch)
            }
        }
        if !DataManager.sharedInstance.canAccessLoadBoard{
            if let indexOfLoadBoard = menuValues.index(of: .loadBoard){
                menuValues.remove(at: indexOfLoadBoard)
            }
        }
        
        tableView.reloadData()
    }
    
    func signInButtonAction(){
        if let index = menuValues.index(of:.login){
            tableView(tableView, didSelectRowAt: IndexPath(row: index, section: 1))
        }
    }
}

extension SideMenuViewController
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else{
            return menuValues.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sideHeaderCell", for: indexPath) as! SideMenuHeaderCell
            cell.signInBtnAction = {
                self.signInButtonAction()
            }
            cell.setupCell()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell", for: indexPath) as! SideMenuTableCell
            let isCellSelected = selectedLeftMenuItem == menuValues[indexPath.row]
            cell.titleLabel.text = menuValues[indexPath.row].titleText
            cell.titleLabel.textColor = isCellSelected ? UIColor.white : UIColor.black
            cell.iconImageView.image = isCellSelected ? UIImage(named: menuValues[indexPath.row].selectImage!) : UIImage(named: menuValues[indexPath.row].unSelectImage!)
            cell.backgroundColor = isCellSelected ? UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1) : UIColor.white
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let menuWidth = tableView.bounds.size.width
        let imageAspectRatio = CGFloat(16)/9
        let imageHeight = menuWidth / imageAspectRatio
        let numOfRows = menuValues.count //2 for headerview being nearly twice the size of cell
        if indexPath.section == 0 {
            return imageHeight
        }
        else {
            return min(75, max(20,(view.frame.size.height-imageHeight) / CGFloat(numOfRows)))
        }
    }
    
    func getViewControllerFor(menu: LeftMenuItem) -> UIViewController? {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController : UIViewController? = nil
        if let vcIdentifier = menu.identifier{
            viewController = storyBoard.instantiateViewController(withIdentifier:vcIdentifier)
        }
        return viewController
    }
}
