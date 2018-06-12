//
//  InitialViewScreen.swift
//  UnitedVision
//
//  Created by Agilink on 30/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class InitialViewScreen: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    class func loadViewFromNib() -> InitialViewScreen {
        return Bundle.main.loadNibNamed("InitialViewScreen", owner: self, options: nil)?.first as! InitialViewScreen
    }
}
