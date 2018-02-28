//
//  ViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate {
    
    @IBOutlet weak var tableView : UITableView!
    
    weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
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
}

//MARK: - TableView delgate

extension HomeViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "LogoTableCell", for: indexPath)
            break;
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PageTableCell", for: indexPath) as! PageTableCell
            cell.carousel.isPagingEnabled = true
            cell.carousel.type = .linear
            cell.carousel.dataSource = self
            cell.carousel.delegate = self
            cell.pageControl.numberOfPages = 5
            cell.pageControl.currentPage = cell.carousel.currentItemIndex
            self.pageControl = cell.pageControl
//            cell.carousel.autoscroll = -0.4

            return cell
        case 2:
            let actionCell = tableView.dequeueReusableCell(withIdentifier: "SplashActionTableCell", for: indexPath) as! SplashActionTableCell
//            cell.locationButton.addTarge
            return actionCell
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableCell", for: indexPath)
            break
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath)
            break
       
        default:
            break
        }

        return cell;
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return indexPath.row == productList.count ? kDefaultCellHeight : kProductCellHeight
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return (productList.count < 1 && !isLogin) ?  0 : (headerView?.frame.height)!
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        return (productList.count < 1 && !isLogin) ? nil : headerView
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        indexPath.row == productList.count ?  self.showCategoryListScreen () : self.showProductDetailScreen(info:
//            productList[indexPath.row])
//    }
//
    
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
        
        itemView.backgroundColor = .red
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

