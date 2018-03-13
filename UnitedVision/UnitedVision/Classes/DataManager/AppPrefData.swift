//
//  AppPrefData.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class AppPrefData: NSObject {

    static let sharedInstance = AppPrefData()
    
    var authToken = ""
    var isLogin = false;
    var searchDict: NSDictionary? = nil

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
            searchDict = dictionary["TractorSearchDict"] as? NSDictionary


        }
    }
    
    func dataAsDictionary() ->  Dictionary<String, Any>
    {
        var dictionary = Dictionary<String, Any>()
        dictionary["authToken"] = self.authToken
        dictionary["isLogin"] = self.isLogin
        
        self.searchDict = self.createTractorSearchDict()
        dictionary["TractorSearchDict"] = self.searchDict
        
        return dictionary
    }
    
    func createTractorSearchDict()-> NSDictionary
    {
        var dict : [String:Any] = [:]
        if let searchInfo = DataManager.sharedInstance.tractorSearchInfo
        {
             dict = ["city" : searchInfo.city, "state": searchInfo.state, "zip": searchInfo.state, "latitude": searchInfo.latitude, "longiude": searchInfo.longitude, "status": searchInfo.status, "radius": searchInfo.radius]
            
            if searchInfo.trailerType.count > 0
            {
                dict["trailerType"] = searchInfo.trailerType
            }
            
            if searchInfo.tractorType.count > 0
            {
                dict["tractorType"] = searchInfo.tractorType
            }
        }
        
        
        return dict as NSDictionary
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
