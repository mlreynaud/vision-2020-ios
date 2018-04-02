//
//  TerminalTableCell.swift
//  UnitedVision
//
//  Created by Agilink on 04/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

protocol TerminalTableCellDelegate : class{
    func callAtIndex (_ cell: TerminalTableCell)
    func showMapAtIndex (_ cell: TerminalTableCell)
}

class TerminalTableCell: UITableViewCell {
    
    var tractorId: String?
    
    @IBOutlet var terminalLbl : UILabel!
    @IBOutlet var destLbl : UILabel!
    @IBOutlet var tractorLbl : UILabel!
    @IBOutlet var trailerLbl : UILabel!
    @IBOutlet var trailerLenLbl : UILabel!
    @IBOutlet var distLbl : UILabel!
    @IBOutlet var statusLbl : UILabel!

    @IBOutlet weak var loadedImageView: UIImageView!
    @IBOutlet weak var hazmatImageView: UIImageView!
    
    @IBOutlet weak var mapBtnView: UIView!
    weak var delegate: TerminalTableCellDelegate?
    
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
    }
    
    func showTractorInfo(_ info:TractorInfo) {
        
        tractorId = info.tractorId
        terminalLbl.attributedText = info.terminal!.createUnderlineString(subString: "", underlineColor: .darkGray)
        destLbl.attributedText = info.destinationCity!.createAttributedString(subString: "", subStringColor: .darkGray)
        tractorLbl.attributedText = info.tractorType!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        trailerLbl.attributedText = info.trailerTypeDescr!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        trailerLenLbl.attributedText = info.trailerLength!.createAttributedString(subString: "", subStringColor: .darkGray)
        distLbl.attributedText = info.distanceFromShipper!.createAttributedString(subString: "", subStringColor: .darkGray)
        
        statusLbl.attributedText = info.status!.createAttributedString(subString: "", subStringColor: .darkGray)
        loadedImageView.image = UIUtils.returnCheckOrCrossImage(str: info.loaded!)
        hazmatImageView.image =  UIUtils.returnCheckOrCrossImage(str: info.hazmat!)
    }
    
    //MARK- Button Action methods
    
    @IBAction func mapBtnPressed(_ sender: Any) {
        delegate?.showMapAtIndex(self)
    }
    
    @IBAction func callButtonAction(_ sender : UIButton) {
        delegate?.callAtIndex(self)
    }

}
