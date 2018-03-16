//
//  FilterTableViewCell.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    var clearHandler: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func clearButtonClick(_ sender: Any) {
        clearHandler()
    }
    
}

class CheckboxFilterTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    var valueChangeHandler: ((_ selected: Bool) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        valueChangeHandler(checkbox.isSelected)
    }
    
    @IBAction func checkBoxAction(_ sender: UIButton?){
        self.isSelected = !self.isSelected
        checkbox.isSelected = self.isSelected
    }
    
}
