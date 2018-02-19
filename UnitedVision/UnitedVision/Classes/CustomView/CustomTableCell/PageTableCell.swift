//
//  PageTableCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 19/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class PageTableCell: UITableViewCell {

    @IBOutlet var carousel: iCarousel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
