//
//  CheckboxTableCell.swift
//  UnitedVision
//
//  Created by Agilink on 05/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class CheckboxTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
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
