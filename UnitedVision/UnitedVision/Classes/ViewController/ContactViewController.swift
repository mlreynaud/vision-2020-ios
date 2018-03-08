//
//  ContactViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 08/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class ContactViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak  var tableView: UITableView!
    
    let departmentList = ["Corporate Headquarters", "Sales", "Driver opprtunities", "Corporate Communications", "Operations", "Brokerage", "Driver Verifications", "Website Support", "Logistics", "Safety", "Driver Qualtifications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Contact Info"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.viewControllers[0].isKind(of: ContactViewController.self))!
        {
            self.setNavigationBarItem()
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

extension ContactViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departmentList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath) as! ContactTableCell
        cell.titleLabel.text = departmentList[indexPath.row]
        
        if (indexPath.row == 0)
        {
            cell.detailLabel.text = """
            4021 Ambassador Caffery Pkwy
            Suite 200 Bldg A
            Lafayette, LA 70503
            Phone: 337-291-6700
            """
        }
        else
        {
            cell.detailLabel.text = """
            Email: Bentley Burgess
            Phone: 713-350-5200
            """
        }
        
        return cell;
    }
}
