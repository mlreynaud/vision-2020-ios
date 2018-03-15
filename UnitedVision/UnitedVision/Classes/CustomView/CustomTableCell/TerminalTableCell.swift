//
//  TerminalTableCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 04/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

protocol TerminalTableCellDelegate : class{
    func callAtIndex (_ cell: TerminalTableCell)
    func showMapAtIndex (_ cell: TerminalTableCell)

}

class TerminalTableCell: UITableViewCell {
    
    @IBOutlet weak var leftFirstLabel: UILabel!
    @IBOutlet weak var leftSecondLabel: UILabel!
    @IBOutlet weak var leftThirdLabel: UILabel!
    @IBOutlet weak var leftFourthLabel: UILabel!
    @IBOutlet weak var leftFifthLabel: UILabel!

    @IBOutlet weak var rightFirstLabel: UILabel!
    @IBOutlet weak var rightSecondLabel: UILabel!

    @IBOutlet weak var loadedImageView: UIImageView!
    @IBOutlet weak var hazmatImageView: UIImageView!
    @IBOutlet weak var mapBtn: UIButton!
    
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
        mapBtn.imageView?.contentMode = .scaleAspectFit
        loadedImageView.image = UIImage(named:"ic_cancel_circle_red")
        hazmatImageView.image = UIImage(named:"ic_cancel_circle_red")
    }
    
    func showTractorInfo(_ info:TractorInfo) {
        
        leftFirstLabel.attributedText = ("TERMINAL: " + info.terminal!).createAttributedString(subString: info.terminal! , subStringColor: .darkGray)
        leftSecondLabel.attributedText = ("DEST: " + info.destinationCity!).createAttributedString(subString: info.destinationCity! , subStringColor: .darkGray)
        leftThirdLabel.attributedText = ("TRACTOR: " + info.tractorType!).createAttributedString(subString: info.tractorType! , subStringColor: .darkGray)
        leftFourthLabel.attributedText = ("TRAILER: " + info.trailerType!).createAttributedString(subString: info.trailerType! , subStringColor: .darkGray)
        
        leftFifthLabel.attributedText = ("TRAILER LENGTH: " + info.trailerLength!).createAttributedString(subString: info.trailerLength! , subStringColor: .darkGray)
        
        rightFirstLabel.attributedText = ("DISTANCE: " + info.distanceFromShipper!).createAttributedString(subString: info.distanceFromShipper! , subStringColor: .darkGray)
        rightSecondLabel.attributedText = ("STATUS: " + info.status!).createAttributedString(subString: info.status! , subStringColor: .darkGray)
        loadedImageView.image = UIUtils.returnCheckOrCrossImage(str: info.loaded!)
        hazmatImageView.image =  UIUtils.returnCheckOrCrossImage(str: info.hazmat!)
    }
    
    //MARK- Button Action methods
    
    @IBAction func mapButtonAction(_ sender : UIButton) {
        delegate?.showMapAtIndex(self)
    }
    
    @IBAction func callButtonAction(_ sender : UIButton) {
        delegate?.callAtIndex(self)
    }

}
