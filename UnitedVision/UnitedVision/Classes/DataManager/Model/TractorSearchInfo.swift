//
//  TractorSearchInfo.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class TractorSearchInfo: NSObject {

    // optional
    var hazmat : String = ""
    var loaded : String = ""
    var showLocal : String = ""
    var status : String = ""
    var terminalId : String = ""
    var tractorId : String = ""
    var tractorType : String = ""
    var trailerType : String = ""
    
    // required
    var radius: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    
    override init() {

    }
    
    init(info : NSDictionary)
    {
        self.radius = info["radius"] as! String
        self.city = info["city"] as! String
        self.state = info["state"] as! String
        self.zip = info["zip"] as! String
        self.status = info["status"] as! String

        if let value =  (info.object(forKey: "latitude") as? NSNumber)?.doubleValue
        {
            latitude = value
        }
        
        if let value =  (info.object(forKey: "longitude") as? NSNumber)?.doubleValue
        {
            longitude = value
        }
    }
}
