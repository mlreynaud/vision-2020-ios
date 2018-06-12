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

protocol BottomBtnCollectionCellProtocol: class{
    func pushVC(withIdentifier identifier:String)
}

class BottomBtnCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnTitleLbl: UILabel!
    
    var leftMenuItem: LeftMenuItem?
    
    weak var delegate: BottomBtnCollectionCellProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setData(bottomMenuItem: LeftMenuItem){
        leftMenuItem = bottomMenuItem
        imageView.image = UIImage(named: bottomMenuItem.bottomBtnImageName)
        btnTitleLbl.text = bottomMenuItem.bottomBtnTitleText ?? ""
     }
    
    @IBAction func btnTapped(_ sender: UIButton) {
        if let vcIdentifier = leftMenuItem?.identifier{
            delegate?.pushVC(withIdentifier: vcIdentifier)
        }
    }
}
