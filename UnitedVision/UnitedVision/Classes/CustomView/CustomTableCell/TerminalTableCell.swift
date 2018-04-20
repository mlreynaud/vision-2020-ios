//
//  TerminalTableCell.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 12/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class TerminalTableCell: UITableViewCell {
    
    @IBOutlet weak var terminalDetailViewDescLbl: UILabel!
    @IBOutlet weak var terminalDetailViewAddressLbl : UILabel!
    @IBOutlet weak var callBtn: UIButton!
    
    weak var locationInfo: LocationInfo?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLocationInfo(locationInfo : LocationInfo){
        self.locationInfo = locationInfo
        terminalDetailViewDescLbl.text = locationInfo.terminalDescr ?? ""
        terminalDetailViewAddressLbl.attributedText = locationInfo.returnDetailLblStr()
    }
    
    @IBAction func callButtonAction(_ sender : UIButton) {
        if let locationInfo = locationInfo{
            if let phNumber = locationInfo.phone{
                UIUtils.callPhoneNumber(phNumber)
            }
        }
    }
}
