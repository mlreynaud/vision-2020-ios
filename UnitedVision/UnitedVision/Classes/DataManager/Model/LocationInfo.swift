//
//  LocationInfo.swift
//  UnitedVision
//
//  Created by Agilink on 07/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LocationInfo: NSObject {

    var id: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var detail: String?

    init(info : Dictionary<String, Any>)
    {
        if let value = info["id"] as? String
        {
            id = value
        }
        
//        latitude = info.value(forKey: "lat") as! Double
//        longitude = info.value(forKey: "lon") as! Double
        
        if let value =  (info["lat"] as? NSNumber)?.doubleValue{
            latitude = value
        }
        
        if let value =  (info["lon"] as? NSNumber)?.doubleValue
        {
            longitude = value
        }
       
        detail = info["description"] as? String
    }

}
