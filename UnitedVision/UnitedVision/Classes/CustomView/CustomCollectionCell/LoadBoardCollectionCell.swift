//
//  LoadBoardCollectionCell.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 12/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LoadBoardCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: CardView!
    
    @IBOutlet weak var originDescLbl: UILabel!
    @IBOutlet weak var destinationDescLbl : UILabel!
    @IBOutlet weak var pickupDateDescLbl: UILabel!
    @IBOutlet weak var deliveryDateDescLbl : UILabel!
    @IBOutlet weak var distanceDescLbl: UILabel!
    @IBOutlet weak var hazmatDescLbl : UILabel!
    @IBOutlet weak var weightDescLbl: UILabel!
    @IBOutlet weak var tractorTypeDescLbl : UILabel!
    
    @IBOutlet weak var estimatedChargeLbl: UILabel!
    
    @IBOutlet weak var callBtn: UIButton!
    
    var phoneNumStr: String?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func callButtonAction(_ sender : UIButton) {
        if let phNumStr = phoneNumStr, !phNumStr.isBlank(){
            UIUtils.callPhoneNumber(phNumStr)
        }
    }
    
    func setCellData(loadBoardInfo: LoadBoardInfo){
        originDescLbl.text = loadBoardInfo.originCityState
        destinationDescLbl.text = loadBoardInfo.destCityState
        pickupDateDescLbl.text = loadBoardInfo.pickupDateStr
        deliveryDateDescLbl.text = loadBoardInfo.deliveryDateStr
        distanceDescLbl.text = "\(loadBoardInfo.distance ?? 0.0)"
        hazmatDescLbl.text = loadBoardInfo.hazmat! ? "Y" : "N"
        weightDescLbl.text = "\(loadBoardInfo.weight ?? 0.0)"
        tractorTypeDescLbl.text = loadBoardInfo.tractorType
        estimatedChargeLbl.text = loadBoardInfo.estimatedCharge
        phoneNumStr = loadBoardInfo.terminalPhone ?? ""
        containerView.sizeToFit()
    }
}
