//
//  SideMenuTableCell.swift
//  UnitedVision
//
//  Created by Agilink on 16/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
