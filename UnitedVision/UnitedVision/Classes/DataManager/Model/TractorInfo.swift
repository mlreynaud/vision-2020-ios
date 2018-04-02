//
//  TractorInfo.swift
//  UnitedVision
//
//  Created by Agilink on 07/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class TractorInfo: NSObject {
    
    var tractorId : String?
    var tractorType: String?
    var tractorTypeDescr: String?
    var trailerType : String?
    var trailerTypeDescr : String?
    
    var trailerLength : String?
    var terminal : String?
    
    var distanceFromShipper: Float?
    var destinationCity: String?
    var originCity: String?
    var status: String?
    var reloadDate: String?
    
    var loaded: String?
    var hazmat: String?
    
    var latitude: Double = 0
    var longitude: Double = 0
    
    init(info : Dictionary<String, Any>)
    {
        tractorId = info["tractorId"] as? String
        tractorType = info["tractorType"] as? String
        tractorTypeDescr = info["tractorTypeDescr"] as? String
        trailerType = info["trailerType"] as? String
        trailerTypeDescr = info["trailerTypeDescr"] as? String
        
        trailerLength = info["trailerLength"] as? String
        terminal = info["terminal"] as? String
        let distStr = info["distanceFromShipper"] as? NSString
        distanceFromShipper = distStr?.floatValue
        destinationCity = info["destinationCity"] as? String
        originCity = info["originCity"] as? String
        
        let statusStr = info["status"] as? String
        status = statusStr == "Delivered" ? "Available" : statusStr
        loaded = info["loaded"] as? String
        reloadDate = info["reloadDate"] as? String
        hazmat = info["hazmat"] as? String
        
        latitude = info["lat"] as! Double
        longitude = info["lon"] as! Double
    }

}


