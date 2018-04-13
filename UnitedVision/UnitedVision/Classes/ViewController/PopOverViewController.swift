//
//  PopOverViewController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 13/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class PopOverViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    var dataList = [String]()
    var titleText = String()
    var isCancelEnabled = false
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var cancelBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewheight: NSLayoutConstraint!
    @IBOutlet weak var backGreyView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var popOverCompletionHandler: ((Int?)->Void)?
    
    class func initiatePopOverVC() -> PopOverViewController{
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return (storyBoard.instantiateViewController(withIdentifier: "PopOverViewController") as? PopOverViewController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        backGreyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundCancelTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cancelBtnHeight.constant = isCancelEnabled ? 33 : 0
        cancelBtn.isHidden = !isCancelEnabled
        titleLbl.text = titleText
        setupTableViewHeight()
    }
    
    func setupTableViewHeight(){
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewheight.constant = min(tableView.contentSize.height,view.frame.height*(3/4))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell(style: .default, reuseIdentifier: "popOverCell")
        cell.textLabel?.text = dataList[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popOverCompletionHandler!(indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundCancelTapped() {
        popOverCompletionHandler!(nil)
        self.dismiss(animated: true, completion: nil)
    }
}
