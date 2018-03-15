//
//  TerminalInfo.swift
//  UnitedVision
//
//  Created by Agilink on 3/13/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class TrailerInfo: NSObject {
    var id: String?
    var descr: String?
    
    init(info : Dictionary<String, Any>) {
        id = (info["id"] as? String) ?? ""
        descr = (info["descr"] as? String) ?? ""
    }
}
