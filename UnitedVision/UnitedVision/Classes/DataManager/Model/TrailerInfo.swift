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
    
    init(info : NSDictionary) {
        id = (info.object(forKey: "id") as? String) ?? ""
        descr = (info.object(forKey: "descr") as? String) ?? ""
    }
}
