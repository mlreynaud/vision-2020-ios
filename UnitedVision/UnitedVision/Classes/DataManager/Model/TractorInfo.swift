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
    var loaded: String?
    var reloadDate: String?
    
    var hazmat: String?
    var latitude: Double = 0
    var longitude: Double = 0
    
    init(info : NSDictionary)
    {
        tractorId = info.object(forKey: "tractorId") as? String
        tractorType = info.object(forKey: "tractorType") as? String
        tractorTypeDescr = info.object(forKey: "tractorTypeDescr") as? String
        trailerType = info.object(forKey: "trailerType") as? String
        trailerTypeDescr = info.object(forKey: "trailerTypeDescr") as? String
        
        trailerLength = info.object(forKey: "trailerLength") as? String
        terminal = info.object(forKey: "terminal") as? String
        distanceFromShipper = info.object(forKey: "distanceFromShipper") as? String
        destinationCity = info.object(forKey: "destinationCity") as? String
        originCity = info.object(forKey: "originCity") as? String
        
        status = info.object(forKey: "status") as? String
        loaded = info.object(forKey: "loaded") as? String
        reloadDate = info.object(forKey: "reloadDate") as? String
        hazmat = info.object(forKey: "hazmat") as? String
        
        latitude = info.value(forKey: "lat") as! Double
        longitude = info.value(forKey: "lon") as! Double

    }

}
