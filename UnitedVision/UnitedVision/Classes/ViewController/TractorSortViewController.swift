//
//  TractorSortViewController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 02/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

enum TractorSortType : String {
    case EDestinationCity = "Destination City"
    case EDistance = "Distance"
    case ETractorType = "Tractor Type"
    case ETerminal = "Terminal"
    case EStatus = "Status"
}

extension TractorSortType {
    static var array: [TractorSortType] {
        var arr: [TractorSortType] = []
        switch TractorSortType.EDestinationCity {
        case .EDestinationCity: arr.append(.EDestinationCity); fallthrough
        case .EDistance: arr.append(.EDistance); fallthrough
        case .ETractorType: arr.append(.ETractorType); fallthrough
        case .ETerminal: arr.append(.ETerminal); fallthrough
        case .EStatus: arr.append(.EStatus);
        }
        return arr
    }
}

class TractorSortViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sortCompletionHandler: ((TractorSortType?)->Void)?

    @IBOutlet weak var tableView: UITableView!
    
    class func initiateTractorSortVC() -> TractorSortViewController{
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return (storyBoard.instantiateViewController(withIdentifier: "TractorSortViewController") as? TractorSortViewController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TractorSortType.array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell  = UITableViewCell(style: .default, reuseIdentifier: "tractorSortCell")
        cell.textLabel?.text = TractorSortType.array[indexPath.row].rawValue
        return cell
    }
    @IBAction func cancelTapped(_ sender: Any) {
        sortCompletionHandler!(nil)
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sortCompletionHandler!(TractorSortType.array[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/CGFloat(TractorSortType.array.count)
    }
}
