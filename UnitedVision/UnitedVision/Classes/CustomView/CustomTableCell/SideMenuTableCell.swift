//
//  SideMenuTableCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 16/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var menuValue: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
