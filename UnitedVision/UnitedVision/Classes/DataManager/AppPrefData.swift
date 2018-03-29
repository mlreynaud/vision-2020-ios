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
    
    var authToken = ""
    var isLogin = false;
    var userName: String?
    var searchDict: Dictionary<String, Any>?

    private override init() {
        super.init()
        self.loadAppPreferenceData()
    }
    
    func loadAppPreferenceData() {
        let defaults = UserDefaults.standard
        if let dictionary = defaults.dictionary(forKey: "keyPreferenceData")
        {
            authToken = (dictionary["authToken"] as? String)!
            isLogin = dictionary["isLogin"] as! Bool
            userName = dictionary["userName"] as? String
            if let tractorSearchDict = dictionary["TractorSearchDict"] as? Dictionary<String,Any> , tractorSearchDict.count > 0{
                searchDict = tractorSearchDict
            }
        }
    }
    
    func dataAsDictionary() ->  Dictionary<String, Any>
    {
        var dictionary = Dictionary<String, Any>()
        dictionary["authToken"] = DataManager.sharedInstance.authToken
        dictionary["isLogin"] = DataManager.sharedInstance.isLogin
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
            
            if searchInfo.trailerType.count > 0{
                dict["trailerType"] = searchInfo.trailerType
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
    
}
