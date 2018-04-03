//
//  RegFieldPickerController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 03/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

class RegFieldPickerController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataList = [String]()
    
    var fieldCompletionHandler: ((String?)->Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    class func initiateRegFieldPicker() -> RegFieldPickerController{
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return (storyBoard.instantiateViewController(withIdentifier: "RegFieldPickerController") as? RegFieldPickerController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell(style: .default, reuseIdentifier: "regFieldCell")
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        fieldCompletionHandler!(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        let selectedIndex = tableView.indexPathForSelectedRow
        fieldCompletionHandler!(dataList[(selectedIndex?.row)!])
        self.dismiss(animated: true, completion: nil)
    }
}

