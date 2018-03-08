//
//  Defines.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import Foundation

// MARK:- Server URLs

let kProductionURL = "http://uv.agilink.net/api/"
let kStagingURL = "http://uv.agilink.net/api/"

let kServerUrl = "http://uv.agilink.net/api2/" //UIUtils.getServerURl()!

let kDefaultRadius = 50 //UIUtils.getServerURl()!

enum FilterType: Int {
    case status = 0
    case tractorType
    case trailerType
    case tractorTerminal
}

enum UserType: Int {
    case none = 1000
    case customer
    case carrier
    case employee
}

let kAppTitle = "United Vision"

let kBlueColor = UIColor(red: 38/255.0, green: 95.0/255.0, blue: 137.0/255.0, alpha: 1.0)
