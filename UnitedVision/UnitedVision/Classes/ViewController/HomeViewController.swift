//
//  ViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import FZAccordionTableView

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate {
    
    static fileprivate let kTableViewCellReuseIdentifier = "AccordionTableCell"

    @IBOutlet weak  var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var tableView : FZAccordionTableView!
        
    let departmentList = ["Corporate Headquarters", "Sales", "Driver opprtunities", "Corporate Communications", "Operations", "Brokerage", "Driver Verifications", "Website Support", "Logistics", "Safety", "Driver Qualtifications"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        let logo = UIImage(named: "DummyLogoImage")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.allowMultipleSectionsOpen = true
        tableView.register(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)

        self.carousel.isPagingEnabled = true
        self.carousel.type = .linear
        self.carousel.dataSource = self
        self.carousel.delegate = self
        self.pageControl.numberOfPages = 5
        self.pageControl.currentPage = self.carousel.currentItemIndex
    }
    
    // MARK: - Button Action
    @IBAction func signInButtonAction()
    {
//        DataManager.sharedInstance.isLogin = true
//        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locationButtonAction()
    {
        //        DataManager.sharedInstance.isLogin = true
        //        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updatePage(pageControl : UIPageControl)
    {
        //        [carousel scrollToItemAtIndex:pageControl.currentPage * 5 aimated:YES];
        
        self.carousel.scrollToItem(at: pageControl.currentPage, animated: true)
    }
}

//MARK: - TableView delgate

extension HomeViewController  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return departmentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccordionHeaderView.kDefaultAccordionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection:section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.kTableViewCellReuseIdentifier, for: indexPath) as! AccordionTableCell
        
        if (indexPath.section == 0)
        {
            cell.textView.text = """
                                4021 Ambassador Caffery Pkwy
                                Suite 200 Bldg A
                                Lafayette, LA 70503
                                Phone: 337-291-6700
                                """
        }
        else
        {
            cell.textView.text = """
                                    Email: Bentley Burgess
                                    Phone: 713-350-5200
                                    """
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier) as! AccordionHeaderView
        headerView.titleLabel.text = departmentList[section]
        return headerView
    }
}

// MARK: - <FZAccordionTableViewDelegate> -

extension HomeViewController : FZAccordionTableViewDelegate {
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
}


//MARK: - iCarousel delgate


extension HomeViewController
{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 5 //items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 250))
            itemView.image = UIImage(named: "page.png")
            itemView.contentMode = .center
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = label.font.withSize(50)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        itemView.backgroundColor = .blue
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = String(index)
        
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

