//
//  FilterSearchViewController.swift
//  UnitedVision
//
//  Created by Agilink on 09/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class FilterSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var backGreyView: UIView!

    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    
    var filterType : FilterType!
    var selectedValue : Any?
    var filterList : [AnyObject] = []

    var completionHandler: ((Any?)->Void)?
    
    @IBOutlet weak var centreLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        backGreyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchViewHeight.constant = view.frame.height*(3/4)
    }
    
    @objc func backgroundTapped() {
        completionHandler?(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        searchViewHeight.constant = size.height*(3/4)
    }
}

extension FilterSearchViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        centreLbl.isHidden =  filterList.count > 0
        return filterList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSerachTableCell", for: indexPath)
        
        if (filterType == .tractorTerminal) {
            cell.textLabel?.text = filterList[indexPath.row] as? String
        }
        else if (filterType == .trailerType) {
            cell.textLabel?.text = (filterList[indexPath.row] as! TrailerInfo).descr!
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (filterType == .tractorTerminal) {
            selectedValue = filterList[indexPath.row] as! String
        }
        else if (filterType == .trailerType) {
            selectedValue = (filterList[indexPath.row] as! TrailerInfo)
        }
        dismissKeyboard()
        self.completionHandler?(selectedValue)
        self.dismiss(animated: true, completion: nil)
    }
    
}

 extension FilterSearchViewController
{
    func  dismissKeyboard()  {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: - SearchView delgate
    func searchBarBecomeFirstResponder ()
    {
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let text = searchText.trimmingCharacters(in: CharacterSet.whitespaces)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard (text.count != 0) else{
            searchBar.text = ""
            self.filterList.removeAll()
            self.tableView.reloadData()
            print("No Search String");
            return
        }
        
        self.perform(#selector(FilterSearchViewController.callSearchAPI), with:searchBar.text, afterDelay: 0.5)
    }
    
    @objc func callSearchAPI(_ searchText: String)
    {
        if (filterType == .tractorTerminal)
        {
            DataManager.sharedInstance.requestToSearchTerminal(searchText, completionHandler: {( status, results) in
                
                if let list = results
                {
                    self.filterList = list as [AnyObject]
                }
                else
                {
                    self.filterList = []
                }
                self.tableView.reloadData()
                
            })
        }
        else  if (filterType == .trailerType){
            
            DataManager.sharedInstance.requestToSearchTrailerType(searchText, completionHandler: {( status, results) in

                 if let list = results
                 {
                    self.filterList = list
                }
                else
                 {
                    self.filterList = []
                }
                self.tableView.reloadData()
            })
        }

    }

   
}
