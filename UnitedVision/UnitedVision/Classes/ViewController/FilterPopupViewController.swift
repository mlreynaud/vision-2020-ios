//
//  FilterPopupViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class FilterPopupViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var filterType : FilterType!
    var isMultiSelectionAllow : Bool = false
    
    var selectedList: [String]? = []
    var filterList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fetchFilterList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button action methods
    @IBAction func doneButtonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchFilterList()
    {
       if (filterType == .status)
       {
            filterList = ["Available", "In Transit", "Delivered","All"]
       }
       else{
            filterList = ["Hot Shot", "One Ton", "Mini Float","Single Axle", "Tandem"]
        }
        
        tableView.reloadData()
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

extension FilterPopupViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxTableCell", for: indexPath) as! CheckboxTableCell
        
        cell.titleLabel.text = filterList[indexPath.row]
        
        if (isMultiSelectionAllow)
        {
            cell.imageView?.image = UIImage(named: "unchecked_checkbox")
        }
        else
        {
            cell.imageView?.image = UIImage(named: "radio_uncheck")
        }
        
        return cell;
    }
    
}

