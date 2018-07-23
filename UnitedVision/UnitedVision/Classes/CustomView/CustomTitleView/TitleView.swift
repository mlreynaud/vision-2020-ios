//
//  TitleView.swift
//  UnitedVision
//
//  Created by Agilink on 03/29/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

let defaultTitleViewSize = CGRect(x: 0, y: 0, width: 200, height: 32)

class TitleView : UIView{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    class func loadViewFromNib() -> TitleView {
        return Bundle.main.loadNibNamed("TitleView", owner: self, options: nil)?.first as! TitleView
    }
    func setTitle(Title title:String, Frame newframe:CGRect?) {
        titleLbl.text = title
        frame = newframe ?? defaultTitleViewSize
    }
    
}
