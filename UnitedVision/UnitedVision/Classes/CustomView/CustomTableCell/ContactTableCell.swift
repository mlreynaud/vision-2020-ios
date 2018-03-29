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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setCellData(contactInfo: ContactInfo, indexPath: IndexPath) {
        titleLabel.text = contactInfo.name!
        
        emailButton.isEnabled = (contactInfo.email!.count > 0) ? true : false
        callButton.isEnabled = (contactInfo.phone!.count > 0) ? true : false
        
        let isEmailInfoAvail = (contactInfo.email!.count > 0) ? true : false
        emailButton.isEnabled = isEmailInfoAvail
        emailButton.backgroundColor = isEmailInfoAvail ? UIColor(red: 200/255.0, green: 0/255.0, blue: 40/255.0, alpha: 1.0) : UIColor.lightGray

        let isCallInfoAvail = (contactInfo.phone!.count > 0) ? true : false
        callButton.isEnabled = isCallInfoAvail
        callButton.backgroundColor = isCallInfoAvail ? UIColor(red: 0/255.0, green: 184/255.0, blue: 0/255.0, alpha: 1.0) : UIColor.lightGray
        
        emailButton.tag = indexPath.row
        callButton.tag = indexPath.row
    }
}
