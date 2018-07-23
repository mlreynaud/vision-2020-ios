//
//  LoadBoardSearchInfo.swift
//  UnitedVision
//
//  Created by Agilink 06/12/18.
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
    var originStateAbbrev: String = ""
    
    // Destination Location required
    var destCity: String = ""
    var destState: String = ""
    var destStateAbbrev: String = ""
    
    override init() {}
    
    init(info : Dictionary<String, Any>)
    {
        
        if let value =  (info["originCity"] as? String){
            originCity = value
        }
        
        if let value =  (info["originState"] as? String){
            originState = value
        }
        
        if let value =  (info["originStateAbbrev"] as? String){
            originStateAbbrev = value
        }
        
        if let value =  (info["destCity"] as? String){
            destCity = value
        }
        
        if let value =  (info["destState"] as? String){
            destState = value
        }
        
        if let value =  (info["destStateAbbrev"] as? String){
            destStateAbbrev = value
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
        loadBoardSearchInfo.originStateAbbrev = originStateAbbrev
        
        loadBoardSearchInfo.destCity = destCity
        loadBoardSearchInfo.destState = destState
        loadBoardSearchInfo.destStateAbbrev = destStateAbbrev
        
        return loadBoardSearchInfo
    }
    
    
}
