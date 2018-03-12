//
//  DataManager.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 06/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import CoreLocation

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    var userLocation : CLLocationCoordinate2D?
    var locationList : [LocationInfo] = []
    var tractorList : [TractorInfo] = []
    
    var authToken = ""
    var userType : UserType = .none
    var userTypeStr : String = ""

    var radius = 50

    var isLogin = false

    fileprivate override init() {
        let locationManager = LocationManager.sharedInstance
        locationManager.initializeLocationManager()
         let appPref = AppPrefData.sharedInstance
        self.isLogin = appPref.isLogin
        self.authToken = appPref.authToken
    }
    
    func parseJSONData(_ data: Data?) -> (status: Bool, message: String, count: String, content: Any?){
        
        guard data != nil else {
//            UIUtils.showAlert(withTitle: "Server Error", message: "Please try again later", alertType: .error)
//            UIUtils.vibrate()
            return (false, "Error", "0", nil)
        }
        if let json = UIUtils.getJSONFromData(data as Data!) as? NSDictionary {
            let status = json.object(forKey: "success") as? Bool
            let message = json.object(forKey: "message") as? String
            var count = json.object(forKey: "totalCount") as? Int
            let content = json.object(forKey: "content") as Any
            
            print("JSON response- \(json)")
            
            if count == nil {
                count = Int(json.object(forKey: "totalCount") as! String)
            }
            
            return(status!, message!, String(count!), content)
        }
        else
        {
//            UIUtils.showAlert(withTitle: "Server Error", message: "Please try again later", alertType: .error)
//            UIUtils.vibrate()
            return (false, "Error", "0", nil)
        }
    }
    
    
    func readJSON(file filename: String) -> Data?
    {
        print(filename)
        let filepath1 = Bundle.main.url(forResource: filename, withExtension: "json")
        if let filepath = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filepath), options: .alwaysMapped)
                return data
//                print(contents)
            } catch {
                print ("contents could not be loaded")
            }
        } else {
            print("File not found")
        }
        return nil
    }
    
    func parseLocationInfo()
    {
        let data = self.readJSON(file: "loctaion")
        var list = [LocationInfo]()
        
        if let json = UIUtils.getJSONFromData(data as Data!) as? NSArray
        {
            for dict in json
            {
                let info = LocationInfo(info: (dict as? NSDictionary)!)
                list.append(info)
            }
        }
        
        self.locationList = list
    }
    
    func parseTractorInfo()
    {
        let data = self.readJSON(file: "tractor")
        var list = [TractorInfo]()
        
        if let json = UIUtils.getJSONFromData(data as Data!) as? NSArray
        {
            for dict in json
            {
                let info = TractorInfo(info: (dict as? NSDictionary)!)
                list.append(info)
            }
        }
        
        self.tractorList = list
    }
    
    func request(toLogin username: String, withPassword password: String, completionHandler handler: @escaping ( Bool, String) -> () ) {
        
        let service: String = String(format:"auth/service/login")
        
        let postParams = ["username": username.encodeString(), "password": password.encodeString()] as Dictionary<String, String>
        //let postString = "username=\(username.encodeString())&password=\(password.encodeString())"
       let request: URLRequest = WebServiceManager.postRequest(service: service, withPostDict: postParams) as URLRequest
       // let request = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {[unowned self] (data, error) in
            
            guard  let responseStr : String = String(data: data! as Data, encoding: .utf8),
                    responseStr.count != 0
                    else {
                        handler(false, "Login failed")
                        return
                }
                
                self.userType = self.checkUserType(responseStr)
                self.userTypeStr = (self.userType == .none) ? "" : responseStr
            
                (self.userType == .none) ? handler(false, "Login failed") : handler(true, "Login sucessfull")
        })
    }
    
    func requestToCheckTokenValidity(completionHandler handler: @escaping ( Bool, String) -> () ) {
        
        let token = AppPrefData.sharedInstance.authToken
        if (token.count == 0)
        {
            handler (false, "Empty Token")
            return
        }
        
        let service: String = String(format:"auth/service/checkToken")
        let postParams = [String: String]() // Empty dict
        

        let request: URLRequest = WebServiceManager.postRequest(service: service, withPostDict: postParams) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {[unowned self] (data, error) in
            
            guard  let responseStr : String = String(data: data! as Data, encoding: .utf8),
                responseStr.count != 0
                else {
                    handler(false, "Invalid Token")
                    return
            }
            
            self.userType = self.checkUserType(responseStr)
            self.userTypeStr = (self.userType == .none) ? "" : responseStr
            
            (self.userType == .none) ? handler(false, "Invalid Token") : handler(true, "Valid Token")
        })
    }
    
    func requestToFetchTractorLocations (completionHandler handler: @escaping ( Bool, [LocationInfo]?) -> () ) {
        
        let service: String = "location/service/active"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var list = [LocationInfo]()

            do {
//                let outerJSON = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
                let array =  try! JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! NSArray

                for dict in array
                {
                    let info = LocationInfo(info: (dict as? NSDictionary)!)
                    list.append(info)
                    //                let info = TractorInfo(info: (dict as? NSDictionary)!)
                    //                list.append(info)
                }
                
            }
            catch{
                print(error)
            }
            
            self.locationList = list
            handler(true, list)
        })
    }
    
    func requestToSearchTractor(_ info: TractorSearchInfo, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
        
       // http://uv.agilink.net/api2/tractor/service/search?radius=100&city=Lafayette&state=LA&zip=70508&lat=30.2241&lon=-92.0198
        
        let service: String =  "tractor/service/search?radius=100&city=Lafayette&state=LA&zip=70508&lat=30.2241&lon=-92.0198"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var list = [TractorInfo]()

            do {
                
//                guard   let outerJSON : String = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as? String,
//                     outerJSON.count != 0,
//                    let array =  try! JSONSerialization.jsonObject(with: outerJSON.data(using: .utf8)!, options: .allowFragments) as? NSArray
//                    else {
//                        handler(false, nil)
//                        return
//                    }
//
                let array =  try! JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! NSArray
                
                for dict in array
                {
                    let info = TractorInfo(info: (dict as? NSDictionary)!)
                    list.append(info)
                }
            }
            catch{
                print(error)
            }
            
            self.tractorList = list
            handler(true, list)
        })
    }
    
    func requestToSearchTrailerType(_ search: String, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
        let service: String =  "trailer/service/lookup?Searchstr=\(search)"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
//            var list = [TractorInfo]()
//
//            do {
//
//                guard   let outerJSON : String = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as? String,
//                    outerJSON.count != 0,
//                    let array =  try! JSONSerialization.jsonObject(with: outerJSON.data(using: .utf8)!, options: .allowFragments) as? NSArray
//                    else {
//                        handler(false, nil)
//                        return
//                }
//
//                for dict in array
//                {
//                    let info = TractorInfo(info: (dict as? NSDictionary)!)
//                    list.append(info)
//                }
//            }
//            catch{
//                print(error)
//            }
//
//            self.tractorList = list
            handler(true, nil)
        })
    }
    
    func requestToSearchTerminal(_ search: String, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
        let service: String =  "terminal/service/lookup?Searchstr=\(search)"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            //            var list = [TractorInfo]()
            //
            //            do {
            //
            //                guard   let outerJSON : String = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as? String,
            //                    outerJSON.count != 0,
            //                    let array =  try! JSONSerialization.jsonObject(with: outerJSON.data(using: .utf8)!, options: .allowFragments) as? NSArray
            //                    else {
            //                        handler(false, nil)
            //                        return
            //                }
            //
            //                for dict in array
            //                {
            //                    let info = TractorInfo(info: (dict as? NSDictionary)!)
            //                    list.append(info)
            //                }
            //            }
            //            catch{
            //                print(error)
            //            }
            //
            //            self.tractorList = list
            handler(true, nil)
        })
    }
    
    func checkUserType(_ user: String) -> UserType
    {
        var type : UserType = .none
        if (user == "Customer")
        {
            type = .customer
        }
        else if (user == "Carrier")
        {
            type = .carrier
        }
        else if (user == "Employee")
        {
            type = .employee
        }
        return type
    }
    
    func getRadiusList() -> [String]
    {
        var radiusList : [String] = []
        var value = 25
        for i in 0...20
        {
            radiusList.append(String(value))
            value += 25
        }
        return radiusList
    }
    

    
 
    

}
