//
//  ViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - TableView delgate

extension HomeViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "LogoTableCell", for: indexPath);
            break;
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "PageTableCell", for: indexPath);
            break;
        case 2:
            var actionCell = tableView.dequeueReusableCell(withIdentifier: "SplashActionTableCell", for: indexPath) as! SplashActionTableCell
//            cell.locationButton.addTarge
            return actionCell;
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableCell", for: indexPath);
            break;
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath);
            break;
       
        default:
            break;
        }

        return cell;
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return indexPath.row == productList.count ? kDefaultCellHeight : kProductCellHeight
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return (productList.count < 1 && !isLogin) ?  0 : (headerView?.frame.height)!
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        return (productList.count < 1 && !isLogin) ? nil : headerView
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        indexPath.row == productList.count ?  self.showCategoryListScreen () : self.showProductDetailScreen(info:
//            productList[indexPath.row])
//    }
//
    
}

