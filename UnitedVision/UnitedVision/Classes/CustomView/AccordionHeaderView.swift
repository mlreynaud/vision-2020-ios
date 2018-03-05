//
//  AccordionHeaderView.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 05/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import FZAccordionTableView

class AccordionHeaderView: FZAccordionTableViewHeaderView {

    static let kDefaultAccordionHeaderViewHeight: CGFloat = 44.0;
    static let kAccordionHeaderViewReuseIdentifier = "AccordionHeaderViewReuseIdentifier";
    
    @IBOutlet weak var titleLabel: UILabel!

}
