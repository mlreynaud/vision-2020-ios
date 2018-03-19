//
//  NavigationBar.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 19/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 100.0)
    }
    
}
