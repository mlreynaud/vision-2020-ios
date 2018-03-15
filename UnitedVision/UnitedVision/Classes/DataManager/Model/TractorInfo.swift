//
//  TractorInfo.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 07/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
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
    
    var distanceFromShipper: String?
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
        distanceFromShipper = info["distanceFromShipper"] as? String
        destinationCity = info["destinationCity"] as? String
        originCity = info["originCity"] as? String
        
        status = info["status"] as? String
        loaded = info["loaded"] as? String
        reloadDate = info["reloadDate"] as? String
        hazmat = info["hazmat"] as? String
        
        latitude = info["lat"] as! Double
        longitude = info["lon"] as! Double

    }

}


