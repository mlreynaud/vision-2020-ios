//
//  LoadBoardSearchInfo.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 14/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LoadBoardSearchInfo: NSObject, NSCopying {

    // optional
    var hazmat : Bool = false
    var showLocal : String = ""
    var terminalId : String = ""
    var tractorId : String = ""
    var tractorType = [String]()
    
    var trailerTypeId : String = ""
    var trailerTypeDesc : String = ""
    
    // Origin Location required
    var originCity: String = ""
    var originState: String = ""
    var originZip: String = ""
    var originLatitude : Double = 0
    var originLongitude : Double = 0
    
    // Destination Location required
    var destCity: String = ""
    var destState: String = ""
    var destZip: String = ""
    var destLatitude : Double = 0
    var destLongitude : Double = 0
    
    override init() {}
    
    init(info : Dictionary<String, Any>)
    {
        
        if let value =  (info["originCity"] as? String){
            originCity = value
        }
        
        if let value =  (info["originState"] as? String){
            originState = value
        }
        
        if let value =  (info["originZip"] as? String){
            originZip = value
        }
        
        if let value =  (info["originLatitude"] as? NSNumber)?.doubleValue{
            originLatitude = value
        }
        
        if let value =  (info["originLongitude"] as? NSNumber)?.doubleValue{
            originLongitude = value
        }
        
        if let value =  (info["destCity"] as? String){
            destCity = value
        }
        
        if let value =  (info["destState"] as? String){
            destState = value
        }
        
        if let value =  (info["destZip"] as? String){
            destZip = value
        }
        
        if let value =  (info["destLatitude"] as? NSNumber)?.doubleValue{
            destLatitude = value
        }
        
        if let value =  (info["destLongitude"] as? NSNumber)?.doubleValue{
            destLongitude = value
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
        
        if let  value = info["hazmat"] as? Bool{
            hazmat = value
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let loadBoardSearchInfo = LoadBoardSearchInfo()
        
        loadBoardSearchInfo.hazmat = hazmat
        loadBoardSearchInfo.showLocal = showLocal
        loadBoardSearchInfo.terminalId = terminalId
        loadBoardSearchInfo.tractorId = tractorId
        loadBoardSearchInfo.tractorType = tractorType
        loadBoardSearchInfo.trailerTypeId = trailerTypeId
        loadBoardSearchInfo.trailerTypeDesc = trailerTypeDesc
        
        loadBoardSearchInfo.originCity = originCity
        loadBoardSearchInfo.originState = originState
        loadBoardSearchInfo.originZip = originZip
        loadBoardSearchInfo.originLatitude = originLatitude
        loadBoardSearchInfo.originLongitude = originLongitude
        
        loadBoardSearchInfo.destCity = destCity
        loadBoardSearchInfo.destState = destState
        loadBoardSearchInfo.destZip = destZip
        loadBoardSearchInfo.destLatitude = destLatitude
        loadBoardSearchInfo.destLongitude = destLongitude
        
        return loadBoardSearchInfo
    }
    
    
}
