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
    var hazmat : Bool = false
    var loaded : Bool = false
    var showLocal : String = ""
    var status = [String]()
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
    
    init(info : Dictionary<String, Any>)
    {
        if let value =  (info["radius"] as? String)
        {
            radius = value
        }
        
        if let value =  (info["city"] as? String)
        {
            city = value
        }
        
        if let value =  (info["state"] as? String)
        {
            state = value
        }
        
        if let value =  (info["zip"] as? String)
        {
            zip = value
        }
//        self.city = info["city"] as! String
//        self.state = info["state"] as! String
//        self.zip = info["zip"] as! String
//        self.status = info["status"] as! String

        if let value =  (info["latitude"] as? NSNumber)?.doubleValue
        {
            latitude = value
        }
        
        if let value =  (info["longitude"] as? NSNumber)?.doubleValue
        {
            longitude = value
        }
        
        if let value =  (info["status"] as? String)
        {
            status.append(value)
        }
        
        if let value = info["tractorType"] as? String
        {
            tractorType = value
        }
        
        if let value = info["trailerType"] as? String
        {
            trailerType = value
        }
        
        if let value = info["terminalId"] as? String
        {
            terminalId = value
        }
        
        if let value = info["tractorId"] as? String
        {
            tractorId = value
        }
    }
}
