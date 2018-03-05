//
//  FilterViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 04/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//


import UIKit

class FilterViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let filterList = ["Status", "Tractor Type", "Trailer Type", "Tractor Terminal"]
    
    let subList = ["Loaded", "HazMat"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonAction(){

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

extension FilterViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterList.count + subList.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section < filterList.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as! FilterTableViewCell
        
            cell.titleLabel.text = filterList[indexPath.section]
            
            return cell;
        }
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxFilterTableCell", for: indexPath) as! CheckboxFilterTableCell
 
        let index = indexPath.section - filterList.count
        cell.titleLabel.text = subList[index]
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! TerminalSearchViewController
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    //MARK- TerminalTableCell delegate methods
    
    func callAtIndex (_ indexpath: IndexPath)
    {
        
    }
    
    func showMapAtIndex (_ indexpath: IndexPath)
    {
        
    }
    
}
