//
//  Defines.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

// MARK:- Server URLs

let kProductionURL = "http://uv.agilink.net/api/"
let kStagingURL = "http://uv.agilink.net/api/"

let kServerUrl = "http://uv.agilink.net/api2/" //UIUtils.getServerURl()!
//let kServerUrl = "https://api.uvlogistics.com/"

let kDefaultRadius = 50 //UIUtils.getServerURl()!

let kGoogleAPIKey = "AIzaSyA17-66jRmF_LAsluaLm42U255SKZsrY24"

enum FilterType: Int {
    case searchLocation = 0
    case radius
    case status
    case tractorType
    case trailerType
    case tractorTerminal
    case loaded
    case hazmat
}

enum UserType: String {
    case none = ""
    case customer = "Customer"
    case carrier = "Carrier"
    case employee = "Employee"
    case owner = "Owner"
    case driver = "Driver"
    case agent = "Agent"
    case broker = "Broker"
    case pending = "Pending"
    
    public var loadedAccess: Bool {
        switch self {
        case .employee, .agent, .customer:
            return true
        default:
            return false
        }
    }
    public var tractorSearchAccess: Bool{
        switch self {
        case .carrier:
            return false
        default:
            return true
        }
    }
}

enum MapViewType {
    case TerminalType
    case TractorType
}

let kAppTitle = "United Vision"

let kdefaultTractorNumber = "18008808482"

let kBlueColor = UIColor(red: 38/255.0, green: 95.0/255.0, blue: 137.0/255.0, alpha: 1.0)
