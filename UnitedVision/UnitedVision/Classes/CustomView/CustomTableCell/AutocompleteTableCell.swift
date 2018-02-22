//
//  AutocompleteTableCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 21/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class AutocompleteTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
