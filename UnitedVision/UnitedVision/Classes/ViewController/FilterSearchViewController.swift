//
//  FilterSearchViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 09/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class FilterSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var tableView : UITableView!

    var filterType : FilterType!
    var selectedValue : String = ""
    var filterList : [String] = []

    var completionHandler: ((String)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button action methods
    @IBAction func doneButtonAction(_ sender: UIButton)
    {
        self.completionHandler?(selectedValue)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
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

extension FilterSearchViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSerachTableCell", for: indexPath)
        
        cell.textLabel?.text = filterList[indexPath.row]
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedValue = filterList[indexPath.row]
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
        
            
            
//            if isLogin && (headerView?.myItemsSwitch.isOn)!
//            {
//                pageNo = 1
//                getFiltersList(msds: self.msds, categoryList: self.category, noOfFilters: self.filterCount)
//            }
//            else
//            {
//                showMyItems(switchValue: false)
//                isSearching = false
//                setupTableConstants()
//            }
            print("No Search String");
            return
        }
        
        self.perform(#selector(FilterSearchViewController.callSearchAPI), with:searchBar.text, afterDelay: 0.5)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        AppPrefData.sharedInstance.homeSearchText = searchBar.text
//        AppPrefData.sharedInstance.saveAllData()
    }
    
    @objc func callSearchAPI(_ searchText: String)
    {
//        LoadingView.shared.showOverlay()
        if (filterType == .trailerType)
        {
            DataManager.sharedInstance.requestToSearchTerminal(searchText, completionHandler: {( status, results) in
                
                if let list = results
                {
                    self.filterList = list
                }
                else
                {
                    self.filterList = []
                }
                self.tableView.reloadData()

//                LoadingView.shared.hideOverlayView()
                
                
            })
        }
        else  if (filterType == .tractorType){
            
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

//                LoadingView.shared.hideOverlayView()
                
                
            })
        }

    }

   
}
