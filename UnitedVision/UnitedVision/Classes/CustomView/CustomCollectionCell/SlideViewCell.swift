//
//  SlideViewCell.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 02/04/18.
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
