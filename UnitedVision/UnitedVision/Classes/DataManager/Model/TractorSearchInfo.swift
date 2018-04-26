//
//  TractorSearchInfo.swift
//  UnitedVision
//
//  Created by Agilink on 06/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class TractorSearchInfo: NSObject, NSCopying {

    // optional
    var hazmat : Bool = false
    var loaded : Bool = false
    var showLocal : String = ""
    var status = [String]()
    var terminalId : String = ""
    var tractorId : String = ""
    var tractorType = [String]()
    
    var trailerTypeId : String = ""
    var trailerTypeDesc : String = ""
    
    // required
    var radius: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    
    override init() {}
    
    init(info : Dictionary<String, Any>)
    {
        if let value =  (info["radius"] as? String){
            radius = value
        }
        
        if let value =  (info["city"] as? String){
            city = value
        }
        
        if let value =  (info["state"] as? String){
            state = value
        }
        
        if let value =  (info["zip"] as? String){
            zip = value
        }
        
        if let value =  (info["latitude"] as? NSNumber)?.doubleValue{
            latitude = value
        }
        
        if let value =  (info["longitude"] as? NSNumber)?.doubleValue{
            longitude = value
        }
        
        if let value =  (info["status"] as? [String]){
            status.append(contentsOf: value)
        }
        
        if let value = info["tractorType"] as? [String]{
            tractorType.append(contentsOf: value)
        }
        
        if let value = info["trailerTypeId"] as? String{
            trailerTypeId = value
        }
        
        if let value = info["trailerTypeDesc"] as? String{
            trailerTypeDesc = value
        }
        
        if let value = info["terminalId"] as? String{
            terminalId = value
        }
        
        if let value = info["tractorId"] as? String{
            tractorId = value
        }
        
        if let  value = info["loaded"] as? Bool{
            loaded = value
        }
        
        if let  value = info["hazmat"] as? Bool{
            hazmat = value
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let tractorSearchInfo = TractorSearchInfo()
       
        tractorSearchInfo.hazmat = hazmat
        tractorSearchInfo.loaded = loaded
        tractorSearchInfo.showLocal = showLocal
        tractorSearchInfo.status = status
        tractorSearchInfo.terminalId = terminalId
        tractorSearchInfo.tractorId = tractorId
        tractorSearchInfo.tractorType = tractorType
        tractorSearchInfo.trailerTypeId = trailerTypeId
        tractorSearchInfo.trailerTypeDesc = trailerTypeDesc
        tractorSearchInfo.radius = radius
        tractorSearchInfo.city = city
        tractorSearchInfo.state = state
        tractorSearchInfo.zip = zip
        tractorSearchInfo.latitude = latitude
        tractorSearchInfo.longitude = longitude

        return tractorSearchInfo
    }
}

