//
//  HomeTableViewCell.swift
//  UnitedVision
//
//  Created by Agilink on 19/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView : UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
