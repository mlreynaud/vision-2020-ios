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
    
    var selectedValue = ""
    var selectedList: [String] = []
    var filterList: [String] = []
    
    var tractorCompletionHandler: ((String)->Void)?
    var statusFilterCompletionHandler: (([String])->Void)?

    var lastIndexPath : IndexPath?
    
    var isAllSelected = false

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
        if (filterType == .tractorType) {
            self.tractorCompletionHandler?(selectedValue)
        }
        if (filterType == .status)
        {
            self.statusFilterCompletionHandler?(selectedList)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchFilterList()
    {
       if (filterType == .status)
       {
            filterList = ["All", "In Transit", "Delivered"]
            if let status = DataManager.sharedInstance.tractorSearchInfo?.status
            {
                selectedList = status
            }
       }
       else{
            filterList = ["Hot Shot", "One Ton", "Mini Float","Single Axle", "Tandem"]
            if let value = DataManager.sharedInstance.tractorSearchInfo?.tractorType{
                selectedValue = value
            }
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
        
         let value = filterList[indexPath.row]
        cell.titleLabel.text = value
        
        if (isMultiSelectionAllow)
        {
            if (isAllSelected)
            {
                cell.iconImageView?.image = UIImage(named: "checked_checkbox")
            }
            else
            {
                cell.iconImageView?.image = (selectedList.contains(value)) ? UIImage(named: "checked_checkbox") : UIImage(named: "unchecked_checkbox")
            }
        }
        else
        {
            cell.iconImageView?.image = (selectedValue == value) ?  UIImage(named: "radio_check") : UIImage(named: "radio_uncheck")
            if (value == selectedValue){
                lastIndexPath = indexPath
            }
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! CheckboxTableCell
    
        var lastSelectedCell : CheckboxTableCell?
        if let lastIndexpath = lastIndexPath {
            lastSelectedCell   = tableView.cellForRow(at: lastIndexpath) as? CheckboxTableCell
        }
        
        let value = filterList[indexPath.row]

        if (isMultiSelectionAllow)
        {
            if (indexPath.row == 0)
            {
                isAllSelected = !isAllSelected
                selectedList = (isAllSelected) ? filterList : []
            }
            else
            {
                if (selectedList.contains(value))
                {
                    isAllSelected = false
//                    cell.iconImageView?.image = UIImage(named: "unchecked_checkbox")
                    selectedList.remove(at: indexPath.row)
                }
                else{
//                    cell.iconImageView?.image = UIImage(named: "checked_checkbox")
                    selectedList.append(value)
                }
            }
            
            lastIndexPath = indexPath
            tableView.reloadData()
        }
        else
        {
            if (filterType == .tractorType)
            {
                if (value != selectedValue){
                    selectedValue = filterList[indexPath.row]
                     cell.iconImageView?.image = UIImage(named: "radio_check")
                    lastSelectedCell?.iconImageView?.image  = UIImage(named: "radio_uncheck")
                }
                else
                {
                    selectedValue = ""
                    cell.iconImageView?.image = UIImage(named: "radio_uncheck")
                }
                
                lastIndexPath = indexPath
            }
        }
    }
    
}

