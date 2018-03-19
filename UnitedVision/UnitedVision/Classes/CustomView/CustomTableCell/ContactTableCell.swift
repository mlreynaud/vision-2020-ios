//
//  ContactTableCell.swift
//  UnitedVision
//
//  Created by Agilink on 08/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class ContactTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
