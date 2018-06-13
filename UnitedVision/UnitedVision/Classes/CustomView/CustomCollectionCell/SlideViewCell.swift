//
//  SlideViewCell.swift
//  UnitedVision
//
//  Created by Agilink on 02/04/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

class SlideViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
}

class BottomBtnCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnTitleLbl: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setData(bottomMenuItem: LeftMenuItem){
        imageView.image = UIImage(named: bottomMenuItem.bottomBtnImageName)
        btnTitleLbl.text = bottomMenuItem.bottomBtnTitleText ?? ""
     }
}
