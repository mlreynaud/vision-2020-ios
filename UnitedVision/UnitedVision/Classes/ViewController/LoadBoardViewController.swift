//
//  LoadBoardViewController.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 12/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

let kFilterBtnHeight: CGFloat = 45
let kLoadBoardCellHeight: CGFloat = 142

enum LoadBoardSortType : Int {
    case EOrigin = 0
    case EDestinationCity
    case EPickUpDate
    case EDeliveryDate
    case ETractorType
    case ETrailerType
    case EHazmat
    case ETerminal
    
    public var description: String {
        switch self {
        case .EOrigin:
            return "Origin"
        case .EDestinationCity:
            return "Destination City"
        case .EPickUpDate:
            return "Pick Up Date"
        case .EDeliveryDate:
            return "Delivery Date"
        case .ETractorType:
            return "Tractor Type"
        case .ETrailerType:
            return "Trailer Type"
        case .EHazmat:
            return "Hazmat"
        case .ETerminal:
            return "Terminal"
        }
    }
    
    static var array: [String] {
        var arr: [String] = []
        for i in 0...LoadBoardSortType.ETerminal.rawValue{
            arr.append(LoadBoardSortType(rawValue: i)?.description ?? "")
        }
        return arr
    }
}

class LoadBoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    @IBOutlet weak var bottomFilterBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topFilterBtnViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var loadBoardInfoArr = [LoadBoardInfo](){
        didSet {
            emptyLabel.isHidden = loadBoardInfoArr.count != 0
        }
    }
    
    let loadBoardPopUpVC = LoadBoardPopUpVC.initiatePopOverVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "LOAD BOARD", Frame: nil)
        addSortBarBtn()
        setNavigationBarItem()
        fetchLoadBoardData()
    }
    
    func addSortBarBtn() {
        let sortBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        sortBtn.setImage(UIImage(named: "ic_sort_blue"), for: .normal)
        sortBtn.addTarget(self, action:  #selector(sortBtnPressed), for: .touchUpInside)
        let searchBarBtn = UIBarButtonItem(customView: sortBtn)
        self.navigationItem.rightBarButtonItem = searchBarBtn
    }
    
    @objc func sortBtnPressed() {
        let sortPopOver = PopOverViewController.initiatePopOverVC()
        sortPopOver.dataList = LoadBoardSortType.array
        sortPopOver.titleText = kSortBy
        sortPopOver.isCancelEnabled = false
        sortPopOver.popOverCompletionHandler = { (selectedOption) in
            if selectedOption != nil{
                self.performListSortingFor(SortType: LoadBoardSortType(rawValue:selectedOption!)!)
            }
        }
        sortPopOver.modalPresentationStyle = .overCurrentContext
        sortPopOver.modalTransitionStyle = .crossDissolve
        self.present(sortPopOver, animated: true, completion: nil)
    }
    
    func performListSortingFor(SortType sortType:LoadBoardSortType){
        
        if sortType == .EOrigin {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.originCityState)! <  ($1.originCityState)! })
        }
        else if sortType == .EDestinationCity {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.destCityState)! <  ($1.destCityState)! })
        }
        else if sortType == .EPickUpDate {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.pickupDate)! <  ($1.pickupDate)! })
        }
        else if sortType == .EDeliveryDate {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.deliveryDate)! <  ($1.deliveryDate)! })
        }
        else if sortType == .ETractorType {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.tractorType)! <  ($1.tractorType)! })
        }
        else if sortType == .ETrailerType {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.trailerType)! <  ($1.trailerType)! })
        }
        else if sortType == .EHazmat {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.hazmat! ? 1 : 0) <  ($1.hazmat! ? 1 : 0) })
        }
        else if sortType == .ETerminal {
            loadBoardInfoArr = loadBoardInfoArr.sorted(by: { ($0.terminalDesc)! <  ($1.terminalDesc)! })
        }
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        repositionFilterBtn(size: view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {        
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.collectionView.reloadData()
        }
        repositionFilterBtn(size: size)
    }
    
    func repositionFilterBtn(size: CGSize){
        if UIDevice.current.orientation.isLandscape{
            bottomFilterBtnViewHeight.constant = 0
            topFilterBtnViewHeight.constant = kFilterBtnHeight
        }
        else{
            bottomFilterBtnViewHeight.constant = kFilterBtnHeight
            topFilterBtnViewHeight.constant = 0
        }
    }

    func fetchLoadBoardData(){
        
        LoadingView.shared.showOverlay()
        
        DataManager.sharedInstance.getLoadBoardContent { (status, respArr, err) in
            
            LoadingView.shared.hideOverlayView()

            if status, (respArr != nil){
                self.loadBoardInfoArr = (respArr as? [LoadBoardInfo]) ?? [LoadBoardInfo]()
                self.performListSortingFor(SortType: .EPickUpDate)
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func filterButtonAction(){
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let filterCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorFilterViewController") as! TractorFilterViewController
//        filterCtrl.searchInfo = tractorSearchInfo
//        filterCtrl.searchCompletionHandler = {(searchInfo) in
//            self.tractorSearchInfo = searchInfo
//            self.fetchTractorLocations()
//        }
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationController?.pushViewController(filterCtrl, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadBoardInfoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadBoardCell", for: indexPath) as! LoadBoardCollectionCell
        if let loadBoardInfo = loadBoardInfoArr.elementAt(index: indexPath.item) as? LoadBoardInfo{
            cell.setCellData(loadBoardInfo: loadBoardInfo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: kLoadBoardCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let loadBoardInfo = loadBoardInfoArr.elementAt(index: indexPath.item) as? LoadBoardInfo{
            loadBoardPopUpVC.loadBoardInfo = loadBoardInfo
            loadBoardPopUpVC.modalTransitionStyle = .crossDissolve
            loadBoardPopUpVC.modalPresentationStyle = .overCurrentContext
            self.present(loadBoardPopUpVC, animated: true, completion: nil)
        }
    }
}
