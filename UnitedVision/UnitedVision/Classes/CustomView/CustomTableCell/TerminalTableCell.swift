//
//  TerminalTableCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 04/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

protocol TerminalTableCellDelegate : class{
    func callAtIndex (_ indexpath: IndexPath)
    func showMapAtIndex (_ indexpath: IndexPath)

}

class TerminalTableCell: UITableViewCell {
    
    @IBOutlet weak var leftFirstLabel: UILabel!
    @IBOutlet weak var leftSecondLabel: UILabel!
    @IBOutlet weak var leftThirdLabel: UILabel!
    @IBOutlet weak var leftFourthLabel: UILabel!
    @IBOutlet weak var rightFirstLabel: UILabel!
    @IBOutlet weak var rightSecondLabel: UILabel!
    
    @IBOutlet weak var loadedButton: UIButton!
    @IBOutlet weak var hazmartButton: UIButton!
    
    weak var delegate: TerminalTableCellDelegate?

    var indexpath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showTractorInfo(_ info:TractorInfo) {
        
        leftFirstLabel.attributedText = ("TERMINAL: " + info.terminal!).createAttributedString(subString: info.terminal! , subStringColor: .darkGray)
        leftSecondLabel.attributedText = ("TRACTOR: " + info.tractorType!).createAttributedString(subString: info.tractorType! , subStringColor: .darkGray)
        leftThirdLabel.attributedText = ("TRAILER: " + info.trailerType!).createAttributedString(subString: info.trailerType! , subStringColor: .darkGray)
        leftFourthLabel.attributedText = ("TRAILER LENGTH: " + info.trailerLength!).createAttributedString(subString: info.trailerLength! , subStringColor: .darkGray)
        
        rightFirstLabel.attributedText = ("DISTANCE: " + info.distanceFromShipper!).createAttributedString(subString: info.distanceFromShipper! , subStringColor: .darkGray)
        rightSecondLabel.attributedText = ("STATUS: " + info.status!).createAttributedString(subString: info.status! , subStringColor: .darkGray)
        
    }
    
    //MARK- Button Action methods
    
    @IBAction func mapButtonAction(_ sender: UIButton) {
        delegate?.showMapAtIndex(self.indexpath!)
    }
    
    @IBAction func callButtonAction(_ sender: UIButton) {
        delegate?.callAtIndex(self.indexpath!)
    }

}
