//
//  LocationInfo.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 07/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class LocationInfo: NSObject {

    var id: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var detail: String?

    init(info : NSDictionary)
    {
        if let value = info.object(forKey: "id") as? String
        {
            id = value
        }
        
//        latitude = info.value(forKey: "lat") as! Double
//        longitude = info.value(forKey: "lon") as! Double
        
        if let value =  (info.object(forKey: "lat") as? NSNumber)?.doubleValue
        {
            latitude = value
        }
        
        if let value =  (info.object(forKey: "lon") as? NSNumber)?.doubleValue
        {
            longitude = value
        }
       
        detail = info.object(forKey: "description") as? String
    }

}
