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
            
//            userDict = dictionary["UserInfo"] as! NSDictionary?
//
//            if dictionary["SwitchState"] != nil
//            {
//                myItemsSwitchState = dictionary["SwitchState"] as! Bool
//            }
//            else
//            {
//                myItemsSwitchState = false //true
//            }
//            homeSearchText = dictionary["HomeSearchText"] as! String?
//
//            loadFilterState(dictionary: dictionary as NSDictionary)
//            DataManager.sharedInstance.userInfo = UserInfo(info: dictionary["UserInfo"] as! NSDictionary)
            //            userInfo = UserInfo(info: dictionary["UserInfo"] as! NSDictionary)
        }
    }

    
    func dataAsDictionary() ->  Dictionary<String, Any>
    {
        var dictionary = Dictionary<String, Any>()
        dictionary["authToken"] = self.authToken
        dictionary["isLogin"] = self.isLogin
        
//        dictionary["StayLoggedIn"] = self.isLoggedIn
//        dictionary["UserInfo"] = userDict
//        dictionary["HomeSearchText"] = self.homeSearchText
//        dictionary["SwitchState"] = self.myItemsSwitchState
//        dictionary["CatFilterList"] = self.catFilterList
//        dictionary["msdsFilterVal"] = self.msdsFilterVal
        
        return dictionary
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
