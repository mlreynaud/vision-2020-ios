//
//  ViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import FZAccordionTableView

let kNoOfBottomBtns = 3

class HomeViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate,SideMenuLogOutDelegate {
   
    static fileprivate let kTableViewCellReuseIdentifier = "AccordionTableCell"
    static let kSlideViewCellReuseIdentifier = "slideViewCell"

    @IBOutlet weak var loginTractorCardView: CardView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var centreHomeContentLbl: UILabel!
    @IBOutlet weak var topHomeContentLbl: UILabel!
    
    @IBOutlet weak var loginTractorBtnImg: UIImageView!
    @IBOutlet weak var loginTractorBtnLbl: UILabel!
    
    @IBOutlet var carouselViewHeight: NSLayoutConstraint!
    @IBOutlet var centreHomeContentHeight: NSLayoutConstraint!
    @IBOutlet var topHomeContentWidth: NSLayoutConstraint!
    @IBOutlet var btnViewHeight: NSLayoutConstraint!

    var defaultContentStr = "UNITED VISION LOGISTICS has 138 years of combined experience and an established presence across the United States."
    
    let collectionViewImgArr = ["truck_red","truck_rig_sunset" ,"truck","truck2","truck3","truck4"]
    
    var beginTime: Date?
    var initialViewScreen: UIView?
    var collectionViewWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInitialViewScreen()
        checkToken()
        initialSetup()
        fetchHomeContent()
        pageControl.numberOfPages = collectionViewImgArr.count
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
        DataManager.sharedInstance.requestToCheckTokenValidity(completionHandler: {(status) in
            DataManager.sharedInstance.isLogin = status ? true : false
            let timeNow = Date()
            if timeNow.timeIntervalSince(self.beginTime!) > 2{
                self.removeInitialViewScreen()
            }
            else{
                Timer.scheduledTimer(timeInterval: 2 - timeNow.timeIntervalSince(self.beginTime!), target: self, selector: #selector(self.removeInitialViewScreen), userInfo: nil, repeats: false)
            }
            self.checkIfLoggedIn()
        })
    }
    
    func initialSetup(){
        let logo = UIImage(named: "uv_logo_nooutline") // uv1
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height:32)
        self.navigationItem.titleView = imageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLayoutConstraints(forSize: view.frame.size)
        setNavigationBarItem()
        checkIfLoggedIn()
    }
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayoutConstraints(forSize: size)
        let dispatchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            self.collectionView.reloadData()
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
        self.collectionView.reloadData()
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

                UIUtils.showAlert(withTitle: kAppTitle, message: error?.localizedDescription ?? "Something went wrong,Please try again later", inContainer: self)
            }
        }
    }
    
    func sideMenuLogOutPressed() {
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        let ifLoggedIn = DataManager.sharedInstance.isLogin
        if ifLoggedIn{
            let userType = DataManager.sharedInstance.userType
            if userType == .employeeTS || userType == .driver || userType == .agent || userType == .broker || userType == .customer || userType == .carrier{
                if bottomStackView.arrangedSubviews.count != kNoOfBottomBtns{
                    loginTractorCardView.isHidden = false
                    bottomStackView.addArrangedSubview(loginTractorCardView)
                }
                loginTractorBtnImg.image = UIImage(named:"ic_truck_red")
                loginTractorBtnLbl.text = "Tractor Search"
            }
            else{
                if bottomStackView.arrangedSubviews.count == kNoOfBottomBtns{
                    loginTractorCardView.isHidden = true
                    bottomStackView.removeArrangedSubview(loginTractorCardView)
                }
            }
        }
        else{
            if bottomStackView.arrangedSubviews.count != kNoOfBottomBtns{
                loginTractorCardView.isHidden = false
                bottomStackView.addArrangedSubview(loginTractorCardView)
            }
            loginTractorBtnImg.image = UIImage(named:"ic_login_red")
            loginTractorBtnLbl.text = "Login"
        }
        updateLayoutConstraints(forSize: view.frame.size)
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
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
}

extension HomeViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return collectionViewImgArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.kSlideViewCellReuseIdentifier, for: indexPath as IndexPath) as! SlideViewCell
        cell.imageView.image = UIImage(named: collectionViewImgArr[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: carouselViewHeight.constant)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
    }
}
