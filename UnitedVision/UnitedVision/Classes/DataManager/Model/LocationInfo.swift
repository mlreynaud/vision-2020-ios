//
//  LocationInfo.swift
//  UnitedVision
//
//  Created by Agilink on 07/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LocationInfo {
    
    var terminalNumber:String?
    var terminalDescr:String?
    var address1:String?
    var address2:String?
    var city:String?
    var state:String?
    var zip:String?
    var phone:String?
    var latitude:Double = 0
    var longitude:Double = 0
    var corporateOffice:String?
    
    init(info : Dictionary<String, Any>)
    {
        
        if let value = info["terminalNumber"] as? String
        {
            terminalNumber = value
        }
        
        if let value = info["terminalDescr"] as? String
        {
            terminalDescr = value
        }
        if let value = info["address1"] as? String
        {
            address1 = value
        }
        if let value = info["address2"] as? String
        {
            address2 = value
        }
        if let value = info["city"] as? String
        {
            city = value
        }
        if let value = info["state"] as? String
        {
            state = value
        }
        if let value = info["zip"] as? String
        {
            zip = value
        }
        if let value = info["phone"] as? String
        {
            phone = value
        }
        if let value = (info["lat"] as? NSNumber)?.doubleValue
        {
            latitude = value
        }
        
        if let value = (info["lon"] as? NSNumber)?.doubleValue
        {
            longitude = value
        }
        if let value = info["corporateOffice"] as? String
        {
            corporateOffice = value
        }
    }
    
    func returnDetailLblStr() -> NSAttributedString {
        return NSAttributedString(string:"\n\(address1 ?? "")\n\(city ?? ""), \(state ?? "") \(zip ?? "")\n\(phone ?? "")")
    }
    
}
