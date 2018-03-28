//
//  FilterPopupViewController.swift
//  UnitedVision
//
//  Created by Agilink on 05/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class FilterPopupViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var filterType : FilterType!
    
    var selectedList = [String]()
    var filterList = [String]()
    
    var tractorCompletionHandler: (([String])->Void)?
    var statusFilterCompletionHandler: (([String])->Void)?

    var lastIndexPath : IndexPath?
    
    var isAllSelected = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAllSelected = false
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
            self.tractorCompletionHandler?(selectedList)
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
        if (filterType == .status){
            filterList = ["All","In Transit","Delivered"]
            if let status = DataManager.sharedInstance.tractorSearchInfo?.status{
                selectedList = status
            }
        }
        else{
            filterList = ["All","Hot Shot","One Ton","Mini Float","Single Axle","Tandem"]
            if let value = DataManager.sharedInstance.tractorSearchInfo?.tractorType{
                selectedList = value
            }
        }
        
        if selectedList.contains("All") || selectedList.count == filterList.count - 1{
            selectedList = filterList
            isAllSelected = true
        }
        tableView.reloadData()
    }
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
        
        let checkImage: UIImage?
        let unCheckImage: UIImage?
        if filterType == .status{
            checkImage = UIImage(named: "checked_checkbox")
            unCheckImage = UIImage(named: "unchecked_checkbox")
        }else{
            checkImage = UIImage(named: "radio_check")
            unCheckImage = UIImage(named: "radio_uncheck")
        }
        
        if (isAllSelected){
            cell.iconImageView?.image = checkImage
        }
        else{
            cell.iconImageView?.image = (selectedList.contains(value)) ? checkImage : unCheckImage
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let value = filterList[indexPath.item]
        
        if (indexPath.item == 0)
        {
            isAllSelected = !isAllSelected
            selectedList = (isAllSelected) ? filterList : [String]()
        }
        else
        {
            if (selectedList.contains(value))
            {
                if (isAllSelected)
                {
                    let index = selectedList.index(of: "All")
                    selectedList.remove(at: index!)
                }
                isAllSelected = false
                let index = selectedList.index(of: value)
                selectedList.remove(at: index!)
            }
            else{
                selectedList.append(value)
                if selectedList.count == filterList.count - 1 {
                    selectedList.append("All")
                    isAllSelected = true
                }
            }
        }
        tableView.reloadData()
    }
}


