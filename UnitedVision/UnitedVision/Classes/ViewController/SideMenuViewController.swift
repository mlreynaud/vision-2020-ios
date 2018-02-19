//
//  SideMenuViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 16/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//


enum LeftMenu: Int {
    case home = 0
    case login
    case register
    case tractorSearch
    case terminalSearch
    case applyNow
    case contact
}

import UIKit

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var tableView : UITableView!
    var menus = ["Home","Login", "Register", "Tractor Search", "Terminal Search", "Apply Now", "Contact"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            
            switch menu{
            case .login:
                    self.showLoginView()
                    break;
                
            default:
                if let viewCtrl =  self.getViewControllerFor(menu: menu){
                    let navCtrl = UINavigationController(rootViewController: viewCtrl)
                    self.slideMenuController()?.changeMainViewController(navCtrl, close: true)
                }
                break
                
                
            }
           
        }
    }
    
    func getViewControllerFor(menu: LeftMenu) -> UIViewController? {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch menu {
        case .home:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            return viewCtrl
        case .login:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            return viewCtrl
//        case .register:
//            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//            self.slideMenuController()?.changeMainViewController(viewCtrl, close: true)
//            break
        case .tractorSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            return viewCtrl
        case .terminalSearch:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
            return viewCtrl
//        case .applyNow:
//            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//            self.slideMenuController()?.changeMainViewController(viewCtrl, close: true)
//            break
//        case .contact:
//            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//            self.slideMenuController()?.changeMainViewController(viewCtrl, close: true)
//            break
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
