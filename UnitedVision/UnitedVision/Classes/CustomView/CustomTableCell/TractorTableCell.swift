//
//  TractorTableCell.swift
//  UnitedVision
//
//  Created by Agilink on 04/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

protocol TractorTableCellDelegate : class{
    func showMapAtIndex (_ cell: TractorTableCell)
}

class TractorTableCell: UITableViewCell {
    
    @IBOutlet weak var loadedLbl: UILabel!
    @IBOutlet weak var loadedViewWidth: NSLayoutConstraint!
    @IBOutlet weak var trailerLengthLbl: UILabel!
    @IBOutlet weak var trailerTitleLbl: UILabel!
    @IBOutlet var titleLblCollection: [UILabel]!
    
    @IBOutlet var terminalLbl : UILabel!
    @IBOutlet var destLbl : UILabel!
    @IBOutlet var tractorLbl : UILabel!
    @IBOutlet var trailerLbl : UILabel!
    @IBOutlet var trailerLenLbl : UILabel!
    @IBOutlet var distLbl : UILabel!
    @IBOutlet var statusLbl : UILabel!

    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var loadedImageView: UIImageView!
    @IBOutlet weak var hazmatImageView: UIImageView!
    
    @IBOutlet weak var mapBtnView: UIView!
    weak var delegate: TractorTableCellDelegate?
    var tractorId: String?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func reduceFontSizeForSmallerIPhone(){
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhone4_4S{
            for lbl in titleLblCollection{
                lbl.font = lbl.font.withSize(11)
            }
            trailerLengthLbl.font = trailerLengthLbl.font.withSize(11)
            trailerTitleLbl.font = trailerTitleLbl.font.withSize(11)
            terminalLbl.font = terminalLbl.font.withSize(11)
            destLbl.font = destLbl.font.withSize(11)
            tractorLbl.font = tractorLbl.font.withSize(11)
            trailerLbl.font = trailerLbl.font.withSize(11)
            trailerLenLbl.font = trailerLenLbl.font.withSize(11)
            distLbl.font = distLbl.font.withSize(11)
            statusLbl.font = statusLbl.font.withSize(11)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            delegate?.showMapAtIndex(self)
        }
    }
    
    func setupCell(){
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderColor  =  UIColor.clear.cgColor
        contentView.layer.borderWidth = 5.0
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowColor =  UIColor.lightGray.cgColor
        contentView.layer.shadowRadius = 5.0
        contentView.layer.shadowOffset = CGSize(width:5, height: 5)
        contentView.layer.masksToBounds = true
        loadedImageView.image = UIImage(named:"ic_cancel_circle_red")
        hazmatImageView.image = UIImage(named:"ic_cancel_circle_red")
        reduceFontSizeForSmallerIPhone()
        callBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    func setTractorInfo(tractorInfo:TractorInfo) {
        tractorId = tractorInfo.tractorId ?? ""
        terminalLbl.attributedText = tractorInfo.terminal!.createUnderlineString(subString: "", underlineColor: .darkGray)
        destLbl.attributedText = tractorInfo.destinationCity!.createAttributedString(subString: "", subStringColor: .darkGray)
        tractorLbl.attributedText = tractorInfo.tractorType!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        trailerLbl.attributedText = tractorInfo.trailerType!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        trailerLenLbl.attributedText = tractorInfo.trailerLength!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        let distStr = "\(tractorInfo.distanceFromShipper ?? 0.00)mi"
        distLbl.attributedText = (distStr == "0.00mi" ? "" : distStr).createAttributedString(subString: "", subStringColor: .darkGray)
        statusLbl.attributedText = tractorInfo.status!.createAttributedString(subString: "", subStringColor: .darkGray)
        loadedImageView.image = UIUtils.returnCheckOrCrossImage(str: tractorInfo.loaded ?? "")
        hazmatImageView.image =  UIUtils.returnCheckOrCrossImage(str: tractorInfo.hazmat ?? "")
        
        trailerLengthLbl.isHidden = tractorInfo.trailerLength == ""
        trailerTitleLbl.isHidden = tractorInfo.trailerType == ""
        
        let userType = DataManager.sharedInstance.userType
        let isLoadedViewVisible = (userType == .employeeTS || userType == .agent || userType == .customer)
        loadedViewWidth.constant = isLoadedViewVisible ? loadedViewWidth.constant : 0
        loadedLbl.isHidden = !isLoadedViewVisible
        loadedImageView.isHidden = !isLoadedViewVisible
    }
    
    //MARK- Button Action methods
    
    @IBAction func mapBtnPressed(_ sender: Any) {
        delegate?.showMapAtIndex(self)
    }
    
    @IBAction func callButtonAction(_ sender : UIButton) {
        DataManager.sharedInstance.addNewCallLog(tractorId!, userId:DataManager.sharedInstance.userName!)
        UIUtils.callPhoneNumber(kdefaultTractorNumber)
    }

}
