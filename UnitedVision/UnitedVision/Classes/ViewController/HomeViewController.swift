//
//  ViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import FZAccordionTableView

class HomeViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, iCarouselDataSource, iCarouselDelegate {
    
    static fileprivate let kTableViewCellReuseIdentifier = "AccordionTableCell"

    @IBOutlet weak  var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView : UICollectionView!
    
    var itemList : [String]!
    var imageList : [String]!

//    @IBOutlet weak var tableView : FZAccordionTableView!
    
    let pageList = ["truck_red", "truck", "truck_rig_sunset"];
        
    let departmentList = ["Corporate Headquarters", "Sales", "Driver opprtunities", "Corporate Communications", "Operations", "Brokerage", "Driver Verifications", "Website Support", "Logistics", "Safety", "Driver Qualtifications"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCollectionList()
        self.setNavigationBarItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup()
    {
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeViewController.kTableViewCellReuseIdentifier)
        
        let logo = UIImage(named: "uv1")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
//        tableView.allowMultipleSectionsOpen = true
//        tableView.register(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)

        self.carousel.isPagingEnabled = true
        self.carousel.type = .linear
        self.carousel.dataSource = self
        self.carousel.delegate = self
        self.pageControl.numberOfPages = self.pageList.count
        self.pageControl.currentPage = self.carousel.currentItemIndex
        
    }
    
    func updateCollectionList()
    {
        if (DataManager.sharedInstance.isLogin)
        {
            itemList = ["Contact Us", "Terminal Search", "Tractor Search"];
            imageList = ["ic_call_red", "ic_location_red", "ic_truck_red"];

        }
        else
        {
            itemList = ["Contact Us", "Terminal Search", "Login"];
            imageList = ["ic_call_red", "ic_location_red", "ic_login_red"];

        }
        
        collectionView.reloadData()
    }

    @IBAction func updatePage(pageControl : UIPageControl)
    {
        //        [carousel scrollToItemAtIndex:pageControl.currentPage * 5 aimated:YES];
        
        self.carousel.scrollToItem(at: pageControl.currentPage, animated: true)
    }
}

//MARK: - TableView delgate

//extension HomeViewController  {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return departmentList.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return AccordionHeaderView.kDefaultAccordionHeaderViewHeight
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.tableView(tableView, heightForRowAt: indexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return self.tableView(tableView, heightForHeaderInSection:section)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.kTableViewCellReuseIdentifier, for: indexPath) as! AccordionTableCell
//        
//        if (indexPath.section == 0)
//        {
//            cell.textView.text = """
//                                4021 Ambassador Caffery Pkwy
//                                Suite 200 Bldg A
//                                Lafayette, LA 70503
//                                Phone: 337-291-6700
//                                """
//        }
//        else
//        {
//            cell.textView.text = """
//                                    Email: Bentley Burgess
//                                    Phone: 713-350-5200
//                                    """
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier) as! AccordionHeaderView
//        headerView.titleLabel.text = departmentList[section]
//        return headerView
//    }
//}
//
//// MARK: - <FZAccordionTableViewDelegate> -
//
//extension HomeViewController : FZAccordionTableViewDelegate {
//    
//    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
//        
//    }
//    
//    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
//        
//    }
//    
//    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
//        
//    }
//    
//    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
//        
//    }
//    
//    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
//        return true
//    }
//}


//MARK: - iCarousel delgate


extension HomeViewController
{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return pageList.count //items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 230))
            itemView.contentMode = .scaleAspectFill
            
        }

        let imageName = pageList[index]
        itemView.image = UIImage(named: imageName)
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        //customize carousel display
        switch option
        {
        case .wrap:
            //normally you would hard-code this to YES or NO
            return 1;
        case .spacing:
            //add a bit of spacing between the item views
            return 1.0 //value * 1.05;
//        case .fadeMax:
           
//        case iCarouselOptionShowBackfaces:
//        case iCarouselOptionRadius:
//        case iCarouselOptionAngle:
//        case iCarouselOptionArc:
//        case iCarouselOptionTilt:
//        case iCarouselOptionCount:
//        case iCarouselOptionFadeMin:
//        case iCarouselOptionFadeMinAlpha:
//        case iCarouselOptionFadeRange:
//        case iCarouselOptionOffsetMultiplier:
//        case iCarouselOptionVisibleItems:
        default:
            return value;
        }
//        if (option == .spacing) {
//            return value * 1.1
//        }
//        return value
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel)
    {
        self.pageControl.currentPage = carousel.currentItemIndex
    }
}

extension HomeViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return itemList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath as IndexPath) as! HomeCollectionCell
        
        cell.titleLabel.text = itemList[indexPath.row];
        cell.iconImageVIew.image = UIImage(named: imageList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch indexPath.row {
        case 0:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        case 1:
            let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TerminalSearchViewController") as! TerminalSearchViewController
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        case 2:
            if (DataManager.sharedInstance.isLogin)
            {
                let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "TractorViewController") as! TractorViewController
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }
            else
            {
                let viewCtrl = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }
        default:
            break
        }        
    }
        
        
}
        

