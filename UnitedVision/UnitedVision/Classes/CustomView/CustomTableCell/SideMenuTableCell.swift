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
class SideMenuHeaderCell: UITableViewCell {
    
    var signInBtnAction: (()->Void)?
    
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func setupCell(){
        if (DataManager.sharedInstance.isLogin){
            let userName = DataManager.sharedInstance.userName ?? ""
            titleLabel.text = "Welcome " + userName
            titleBtn.isHidden = true
        } else{
            let textString = "Welcome Sign In"
            titleLabel.attributedText = textString.createUnderlineString(subString: "Sign In", underlineColor: UIColor.black)
            titleBtn.isHidden = false
        }
    }
    
    @IBAction func titleBtnPressed(_ sender: UIButton) {
        signInBtnAction!()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
