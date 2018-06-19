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
    
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    
    var tractorSearchfilterType : TractorSearchFilterType?
    var lbSearchfilterType: LoadBoardSearchFilterType?
    
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
        searchViewHeight.constant = view.frame.size.height*(3/4)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        searchViewHeight.constant = size.height*(3/4)
    }

    //MARK: Button action methods
    @IBAction func doneButtonAction(_ sender: UIButton)
    {
        if tractorSearchfilterType == .tractorType {
            self.tractorCompletionHandler?(selectedList)
        }
        if tractorSearchfilterType == .status{
            self.statusFilterCompletionHandler?(selectedList)
        }
        if lbSearchfilterType == .tractorType{
            self.tractorCompletionHandler?(selectedList)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton)
    {
        tractorSearchfilterType = nil
        lbSearchfilterType = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchFilterList()
    {
        if tractorSearchfilterType == .status{
            filterList = ["All","In Transit","Available"]
        }
        else if tractorSearchfilterType == .tractorType || lbSearchfilterType == .tractorType {
            filterList = ["All","Hot Shot","One Ton","Mini Float","Single Axle","Tandem"]
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
        
        if (isAllSelected){
            cell.iconImageView.isHighlighted = true
        }
        else{
            cell.iconImageView.isHighlighted = selectedList.contains(value)
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


