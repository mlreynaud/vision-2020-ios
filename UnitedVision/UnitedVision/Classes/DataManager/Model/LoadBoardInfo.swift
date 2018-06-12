//
//  LoadBoardInfo.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 12/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

class LoadBoardInfo {
    
    var terminalDesc: String?
    var terminalPhone: String?
    var originCityState: String?
    var destCityState: String?
    var pickupDate: String?
    var deliveryDate: String?
    var tractorType: String?
    var trailerType: String?
    var commodityDesc: String?
    var weight: Double?
    var distance: Double?
    var hazmat: Bool?
    var estimatedCharge: String?
    var orderId: String?
    
    init(loadBoardDict : Dictionary<String, Any>)
    {
        terminalDesc = (loadBoardDict["terminalDescr"] as? String) ?? ""
        terminalPhone = (loadBoardDict["terminalPhone"] as? String) ?? ""
        originCityState = (loadBoardDict["originCityState"] as? String) ?? ""
        destCityState = (loadBoardDict["destCityState"] as? String) ?? ""
        pickupDate = (loadBoardDict["pickupDT"] as? String) ?? "" // mm/dd/yyyy HH:MM
        deliveryDate = (loadBoardDict["deliveryDT"] as? String) ?? ""
        tractorType = (loadBoardDict["tractorType"] as? String) ?? ""
        trailerType = (loadBoardDict["trailerType"] as? String) ?? ""
        commodityDesc = (loadBoardDict["commodityDescr"] as? String) ?? ""
        weight = (loadBoardDict["weight"] as? NSString)?.doubleValue ?? Double(0)
        distance = (loadBoardDict["distance"] as? NSString)?.doubleValue ?? Double(0)
        hazmat = ((loadBoardDict["hazmat"] as? String) ?? "N") == "Y"
        estimatedCharge = (loadBoardDict["estimatedCharge"] as? String) ?? ""
        orderId = (loadBoardDict["orderId"] as? String) ?? ""
    }
    
}
