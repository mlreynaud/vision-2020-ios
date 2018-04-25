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
    var searchDict: Dictionary<String, Any>?

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
                searchDict = tractorSearchDict
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
        self.searchDict = self.createTractorSearchDict()
        dictionary["TractorSearchDict"] = self.searchDict
        
        return dictionary
    }
    
    func createTractorSearchDict()-> Dictionary<String, Any>
    {
        var dict = Dictionary<String, Any>()
        if let searchInfo = DataManager.sharedInstance.tractorSearchInfo
        {
            dict = ["city" : searchInfo.city, "state": searchInfo.state, "zip": searchInfo.zip, "latitude": searchInfo.latitude, "longitude": searchInfo.longitude, "radius": searchInfo.radius, "loaded": searchInfo.loaded, "hazmat": searchInfo.hazmat]
            
            dict["status"] = searchInfo.status
            
            if searchInfo.trailerTypeId.count > 0{
                dict["trailerTypeId"] = searchInfo.trailerTypeId
            }
            
            if searchInfo.trailerTypeDesc.count > 0{
                dict["trailerTypeDesc"] = searchInfo.trailerTypeDesc
            }
            
            if searchInfo.terminalId.count > 0{
                dict["terminalId"] = searchInfo.terminalId
            }
            if searchInfo.tractorType.count > 0{
                dict["tractorType"] = searchInfo.tractorType
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
