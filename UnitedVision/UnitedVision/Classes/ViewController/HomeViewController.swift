//
//  ViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import FZAccordionTableView

let kMaxBottomCellInRow = 4
let kCellSizeSpacingRatio: CGFloat = 0.4
let kCellSizeCollectionViewHeightRatio: CGFloat = 0.7

class HomeViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate ,SideMenuLogOutDelegate {
    
    static let kSlideViewCellReuseIdentifier = "slideViewCell"
    static let kBottomCellReuseIdentifier = "BottomBtnCollectionCell"
    
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    
    @IBOutlet weak var topCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var autoScrollTimer: Timer?
    
    @IBOutlet weak var centreHomeContentLbl: UILabel!
    @IBOutlet weak var topHomeContentLbl: UILabel!
    
    @IBOutlet weak var loginTractorBtnImg: UIImageView!
    @IBOutlet weak var loginTractorBtnLbl: UILabel!
    
    @IBOutlet var carouselViewHeight: NSLayoutConstraint!
    @IBOutlet var centreHomeContentHeight: NSLayoutConstraint!
    @IBOutlet var topHomeContentWidth: NSLayoutConstraint!
    @IBOutlet var btnViewHeight: NSLayoutConstraint!

    var defaultContentStr = "UNITED VISION LOGISTICS has 138 years of combined experience and an established presence across the United States."
    
    let topCollectionViewImgArr = ["truck_red","truck_rig_sunset" ,"truck","truck2","truck3","truck4"]
    
    var bottomCollectionViewImgArr = [LeftMenuItem]()
    
    var beginTime: Date?
    var initialViewScreen: UIView?
    var collectionViewWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInitialViewScreen()
        checkToken()
        initialSetup()
        fetchHomeContent()
        pageControl.numberOfPages = topCollectionViewImgArr.count
        self.centreHomeContentLbl.text = self.defaultContentStr
        self.topHomeContentLbl.text = self.defaultContentStr
    }
    
    func showInitialViewScreen(){
        initialViewScreen = InitialViewScreen.loadViewFromNib()
        let window = UIApplication.shared.keyWindow
        initialViewScreen?.frame = window!.bounds;
        initialViewScreen?.clipsToBounds = true
        window!.addSubview(initialViewScreen!)
    }
    
    @objc func removeInitialViewScreen(){
        UIView.animate(withDuration: 0.5, animations: {
            self.initialViewScreen?.alpha = 0.0
        }) { (_) in
            self.initialViewScreen?.removeFromSuperview()
        }
    }
    
    func checkToken() {
        beginTime = Date()
        DataManager.sharedInstance.requestToLoginOrVerifyToken(reqType: .EVerifiyToken, paramDict: nil) { (status, messageStr) in
            let userType = DataManager.sharedInstance.userType
            DataManager.sharedInstance.isLogin = (status && !(userType == .pending || userType == .none))
            let timeNow = Date()
            if timeNow.timeIntervalSince(self.beginTime!) > 2{
                self.removeInitialViewScreen()
            }
            else{
                Timer.scheduledTimer(timeInterval: 2 - timeNow.timeIntervalSince(self.beginTime!), target: self, selector: #selector(self.removeInitialViewScreen), userInfo: nil, repeats: false)
            }
            self.checkIfLoggedIn()
        }
    }
    
    func initialSetup(){
        let logo = UIImage(named: "uv_logo_nooutline") // uv1
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height:32)
        self.navigationItem.titleView = imageView
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        updateLayoutConstraints(forSize: view.frame.size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        checkIfLoggedIn()
        startAutoScroll()
        
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1) {
            self.topCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoScrollTimer?.invalidate()
    }
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayoutConstraints(forSize: size)
        let dispatchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.topCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            self.topCollectionViewFlowLayout.invalidateLayout()
            self.bottomCollectionViewFlowLayout.invalidateLayout()

            self.topCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
        }
    }
    
    func updateLayoutConstraints(forSize size:CGSize) {
        if UIDevice.current.orientation.isLandscape{
            collectionViewWidth = size.width/2
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)

            let newSize = CGSize(width: size.width, height: size.height + topBarHeight)
            carouselViewHeight.constant = (newSize.height-40)/2
            topHomeContentWidth.constant = newSize.width/2
            btnViewHeight.constant = (newSize.height-40)/2
            centreHomeContentHeight.constant = 0
        }
        else{
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
            let newSize = CGSize(width: size.width, height: size.height + topBarHeight)
            collectionViewWidth = newSize.width
            carouselViewHeight.constant = (newSize.height-40)*(2/5)
            topHomeContentWidth.constant = 0
            btnViewHeight.constant = (newSize.height-40)*(2/5)
            centreHomeContentHeight.constant = (newSize.height - 40)*(1/5)
            }
        self.topCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }
    
    func fetchHomeContent() {
        DataManager.sharedInstance.getHomeContent { (status, string, error) in
            if status{
                if let receivedString = string {
                    print(receivedString)
                    self.centreHomeContentLbl.text = receivedString
                    self.topHomeContentLbl.text = receivedString
                }
            }
            else{
                self.centreHomeContentLbl.text = self.defaultContentStr
                self.topHomeContentLbl.text = self.defaultContentStr

                UIUtils.showAlert(withTitle: kAppTitle, message: error?.localizedDescription ?? error?._domain ?? "Something went wrong,Please try again later", inContainer: self)
            }
        }
    }
  
    func startAutoScroll() {
       autoScrollTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector:  #selector(scrollToNextCell), userInfo: nil, repeats: true);
    }
    
    @objc func scrollToNextCell(){
        var nextIndex = IndexPath(item: 0, section: 0)
        if let currIndexPath = topCollectionView.indexPathsForVisibleItems.first{
            if topCollectionView.indexPathsForVisibleItems.first?.item == topCollectionViewImgArr.count - 1{
                nextIndex = IndexPath(item: 0, section: 0)
            }
            else{
                nextIndex = IndexPath(item: currIndexPath.item + 1, section: 0)
            }
            topCollectionView.scrollToItem(at:nextIndex , at: UICollectionViewScrollPosition(), animated: true)
        }
    }
    
    func sideMenuLogOutPressed() {
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        let dataManager = DataManager.sharedInstance
        let ifLoggedIn = dataManager.isLogin
        
        bottomCollectionViewImgArr = [.tractorSearch, .terminalSearch, .contact, .login, .loadBoard]
        
        if ifLoggedIn {
            if let indexOfLogin = bottomCollectionViewImgArr.index(of: .login){
                bottomCollectionViewImgArr.remove(at: indexOfLogin)
            }
        }
        
        if !DataManager.sharedInstance.canAccessTractorSearch{
            if let indexOfTractorSearch = bottomCollectionViewImgArr.index(of: .tractorSearch){
                bottomCollectionViewImgArr.remove(at: indexOfTractorSearch)
            }
        }
        if !DataManager.sharedInstance.canAccessLoadBoard{
            if let indexOfLoadBoard = bottomCollectionViewImgArr.index(of: .loadBoard){
                bottomCollectionViewImgArr.remove(at: indexOfLoadBoard)
            }
        }
        bottomCollectionViewFlowLayout.minimumInteritemSpacing = 4
        bottomCollectionViewFlowLayout.minimumLineSpacing = 4
        bottomCollectionView.reloadData()
    }
    
    @IBAction func contactUsTapped(_ sender: Any) {
        if let contactVCIdentifier = LeftMenuItem.contact.identifier{
            pushVC(withIdentifier: contactVCIdentifier)
        }
    }

    @IBAction func terminalSearchTapped(_ sender: Any) {
        if let terminalSearchVCIdentifier = LeftMenuItem.terminalSearch.identifier{
            pushVC(withIdentifier: terminalSearchVCIdentifier)
        }
    }
    
    @IBAction func loginTractorBtnTapped(_ sender: Any) {
        if let loginTractorVCIdentifier = DataManager.sharedInstance.isLogin ? LeftMenuItem.tractorSearch.identifier : LeftMenuItem.login.identifier{
            pushVC(withIdentifier: loginTractorVCIdentifier)
        }
    }
        
    func pushVC(withIdentifier identifier:String){
        let viewCtrl = storyboard?.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(viewCtrl!, animated: true)
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        topCollectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
}

extension HomeViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return collectionView == topCollectionView ? topCollectionViewImgArr.count : bottomCollectionViewImgArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if collectionView == topCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.kSlideViewCellReuseIdentifier, for: indexPath as IndexPath) as! SlideViewCell
            cell.imageView.image = UIImage(named: topCollectionViewImgArr[indexPath.row])
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.kBottomCellReuseIdentifier, for: indexPath as IndexPath) as! BottomBtnCollectionCell
            if let celldata = bottomCollectionViewImgArr.elementAt(index: indexPath.item) as? LeftMenuItem{
                cell.setData(bottomMenuItem: celldata)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == topCollectionView{
            return CGSize(width: collectionView.frame.size.width,height:floor( carouselViewHeight.constant - 0.1))
        }
        else {
            let cellInOneRow = min(kMaxBottomCellInRow, bottomCollectionViewImgArr.count)
            let dimensionAccToWidth = collectionView.frame.width/(CGFloat(cellInOneRow) + kCellSizeSpacingRatio)
            let dimensionAccToHeight =  collectionView.frame.height * kCellSizeCollectionViewHeightRatio
            let dimension = min(dimensionAccToWidth, dimensionAccToHeight)
            return CGSize(width: dimension, height: dimension)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == topCollectionView{
            pageControl.currentPage = indexPath.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if collectionView == bottomCollectionView{

            let cellInOneRow = min(kMaxBottomCellInRow, bottomCollectionViewImgArr.count)
            
            let dimensionAccToWidth = collectionView.frame.width/(CGFloat(cellInOneRow) + kCellSizeSpacingRatio)
            let dimensionAccToHeight = collectionView.frame.height * kCellSizeCollectionViewHeightRatio
            let cellSize = min(dimensionAccToWidth, dimensionAccToHeight)
            
            let totalCellWidth = cellSize * CGFloat(cellInOneRow)
            
            let totalSpacingWidth = bottomCollectionViewFlowLayout.minimumInteritemSpacing * CGFloat(cellInOneRow)
            
            let leftInset = fabs((collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2)
            let rightInset = leftInset
            
            let totalCellHeight = cellSize * CGFloat(cellInOneRow/bottomCollectionViewImgArr.count)
            
            let totalSpacingHeight = bottomCollectionViewFlowLayout.minimumLineSpacing * CGFloat(cellInOneRow)
            
            let topInset = fabs((collectionView.frame.height - CGFloat(totalCellHeight + totalSpacingHeight)) / 2)
            let bottomInset = topInset
            
            return UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
        }
        return topCollectionViewFlowLayout.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let leftMenuItem = bottomCollectionViewImgArr.elementAt(index: indexPath.item) as? LeftMenuItem{
            if let vcIdentifier = leftMenuItem.identifier{
                pushVC(withIdentifier: vcIdentifier)
            }
        }
    }
}
