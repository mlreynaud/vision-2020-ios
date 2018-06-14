//
//  AppPrefData.swift
//  UnitedVision
//
//  Created by Agilink on 06/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class AppPrefData: NSObject {

    static let sharedInstance = AppPrefData()
    
    var authToken: String?
    var isLogin = false
    var userName: String?
    var deviceUniqueId: String?
    var tractorSearchDict: Dictionary<String, Any>?
    var loadBoardSearchDict: Dictionary<String, Any>?

    private override init() {
        super.init()
        self.loadAppPreferenceData()
    }
    
    func loadAppPreferenceData() {
        let defaults = UserDefaults.standard
        if let dictionary = defaults.dictionary(forKey: "keyPreferenceData")
        {
            authToken = dictionary["authToken"] as? String
            isLogin = ((dictionary["isLogin"] as? Bool) ?? false)!
            userName = dictionary["userName"] as? String
            deviceUniqueId = (dictionary["deviceUniqueId"] as? String) ?? AppPrefData.returnUUIDString()
            if let tractorSearchDict = dictionary["TractorSearchDict"] as? Dictionary<String,Any> , tractorSearchDict.count > 0{
                self.tractorSearchDict = tractorSearchDict
            }
            if let loadBoardSearchDict = dictionary["LoadBoardSearchDict"] as? Dictionary<String,Any> , loadBoardSearchDict.count > 0{
                self.loadBoardSearchDict = loadBoardSearchDict
            }
        }
        else{
            deviceUniqueId = AppPrefData.returnUUIDString()
            var dictionary = Dictionary<String, Any>()
            dictionary["deviceUniqueId"] = self.deviceUniqueId
            defaults.set(dictionary, forKey: "keyPreferenceData")
        }
    }
    
    func dataAsDictionary() ->  Dictionary<String, Any>
    {
        var dictionary = Dictionary<String, Any>()
        
        dictionary["authToken"] = DataManager.sharedInstance.authToken
        dictionary["isLogin"] = DataManager.sharedInstance.isLogin
        dictionary["deviceUniqueId"] = self.deviceUniqueId
        
        if DataManager.sharedInstance.userName != nil{
            dictionary["userName"] = DataManager.sharedInstance.userName
        }
        
        self.tractorSearchDict = self.createTractorSearchDict()
        dictionary["TractorSearchDict"] = self.tractorSearchDict
        
        self.loadBoardSearchDict = self.createLoadBoardSearchDict()
        dictionary["LoadBoardSearchDict"] = self.loadBoardSearchDict
        
        return dictionary
    }
    
    func createTractorSearchDict()-> Dictionary<String, Any>
    {
        var dict = Dictionary<String, Any>()
        if let tractorSearchInfo = DataManager.sharedInstance.tractorSearchInfo
        {
            dict = ["city" : tractorSearchInfo.city, "state": tractorSearchInfo.state, "zip": tractorSearchInfo.zip, "latitude": tractorSearchInfo.latitude, "longitude": tractorSearchInfo.longitude, "originRadius": tractorSearchInfo.radius, "loaded": tractorSearchInfo.loaded, "hazmat": tractorSearchInfo.hazmat]
            
            dict["status"] = tractorSearchInfo.status
            
            if tractorSearchInfo.trailerTypeId.count > 0{
                dict["trailerTypeId"] = tractorSearchInfo.trailerTypeId
            }
            
            if tractorSearchInfo.trailerTypeDesc.count > 0{
                dict["trailerTypeDesc"] = tractorSearchInfo.trailerTypeDesc
            }
            
            if tractorSearchInfo.terminalId.count > 0{
                dict["terminalId"] = tractorSearchInfo.terminalId
            }
            if tractorSearchInfo.tractorType.count > 0{
                dict["tractorType"] = tractorSearchInfo.tractorType
            }
        }
        return dict
    }
    
    func createLoadBoardSearchDict()-> Dictionary<String, Any>
    {
        
        var dict = Dictionary<String, Any>()
        if let loadBoardSearchInfo = DataManager.sharedInstance.loadBoardSearchInfo
        {
            dict["originCity"] = loadBoardSearchInfo.originCity
            dict["originState"] = loadBoardSearchInfo.originState
            dict["originZip"] = loadBoardSearchInfo.originZip
            dict["originLatitude"] = loadBoardSearchInfo.originLatitude
            dict["originLongitude"] = loadBoardSearchInfo.originLongitude
            
            dict["destCity"] = loadBoardSearchInfo.destCity
            dict["destState"] = loadBoardSearchInfo.destState
            dict["destZip"] = loadBoardSearchInfo.destZip
            dict["destLatitude"] = loadBoardSearchInfo.destLatitude
            dict["destLongitude"] = loadBoardSearchInfo.destLongitude

            dict["hazmat"] = loadBoardSearchInfo.hazmat

            if loadBoardSearchInfo.trailerTypeId.count > 0{
                dict["trailerTypeId"] = loadBoardSearchInfo.trailerTypeId
            }

            if loadBoardSearchInfo.trailerTypeDesc.count > 0{
                dict["trailerTypeDesc"] = loadBoardSearchInfo.trailerTypeDesc
            }

            if loadBoardSearchInfo.terminalId.count > 0{
                dict["terminalId"] = loadBoardSearchInfo.terminalId
            }
            if loadBoardSearchInfo.tractorType.count > 0{
                dict["tractorType"] = loadBoardSearchInfo.tractorType
            }
        }
        return dict
    }
    
    func saveAppPreferenceData() {
        let defaults = UserDefaults.standard
        defaults.set(self.dataAsDictionary(), forKey: "keyPreferenceData")
    }
    
    func loadAllData() {
        self.loadAppPreferenceData()
    }
    
    func saveAllData(){
        self.saveAppPreferenceData()
    }
    class func returnUUIDString() -> String{
        let uuid = CFUUIDCreate(nil)
        let cfString = CFUUIDCreateString(nil, uuid)
        let uuidStr = cfString as String?
        return uuidStr!
    }
    
}
