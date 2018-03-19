//
//  PageTableViewCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 19/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell {

    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialSetup()
    {
        
        
    }
    
    @IBAction func updatePage(pageControl : UIPageControl)
    {
        //        [carousel scrollToItemAtIndex:pageControl.currentPage * 5 aimated:YES];
        
        self.carousel.scrollToItem(at: pageControl.currentPage, animated: true)
    }

}
