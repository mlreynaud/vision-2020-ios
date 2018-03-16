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
    var tractorSearchInfo : TractorSearchInfo?
    
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
        
        if let dict = appPref.searchDict //, dict.count != 0
        {
            self.tractorSearchInfo = TractorSearchInfo(info: dict)
        }
        
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
        
        if let json = UIUtils.getJSONFromData(data as Data!) as? [Dictionary<String, Any>]
        {
            for dict in json
            {
                let info = LocationInfo(info:dict)
                list.append(info)
            }
        }
        
        self.locationList = list
    }
    
    func parseTractorInfo()
    {
        let data = self.readJSON(file: "tractor")
        var list = [TractorInfo]()
        
        if let json = UIUtils.getJSONFromData(data as Data!) as? [Dictionary<String, Any>]
        {
            for dict in json
            {
                let info = TractorInfo(info:dict)
                list.append(info)
            }
        }
        
        self.tractorList = list
    }
    
    func request(toLogin username: String, withPassword password: String, completionHandler handler: @escaping ( Bool, String) -> () ) {
        
        let service: String = String(format:"auth/service/login")
        
        let postParams = ["username": username.encodeString(), "password": password.encodeString()] as Dictionary<String, String>
       let request: URLRequest = WebServiceManager.postRequest(service: service, withPostDict: postParams) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {[unowned self] (data, error) in
            
            if error != nil{
                handler(false, "Login failed")
                return
            }
            
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
            
            if error != nil{
                handler(false, "Invalid Token")
                return
            }
            
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
    
    func requestToFetchTerminalLocations (completionHandler handler: @escaping ( Bool, [LocationInfo]?) -> () ) {
        
        let service: String = "location/service/active"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var responseArr = [LocationInfo]()
            var status : Bool = false
            
            if error != nil {
                handler(status, nil)
                return
            }
            
            do{
                if let arr =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [Dictionary<String, Any>]{
                    for dict in arr
                    {
                        let info = LocationInfo(info:dict)
                        responseArr.append(info)
                    }
                    status = true
                }
            }
            catch{
                print(error)
                status = false
            }
            self.locationList = responseArr

            handler(status, responseArr)
        })
    }
    
    func requestToSearchTractor(_ info: TractorSearchInfo, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
       // http://uv.agilink.net/api2/tractor/service/search?radius=100&city=Lafayette&state=LA&zip=70508&lat=30.2241&lon=-92.0198
   
        let params = self.createTractorSearchRequest(info)
        let service: String =  "tractor/service/search?\(params)"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var responseArr = [TractorInfo]()
            var status : Bool = false
            
            if error != nil {
                handler(status, nil)
                return
            }
            
            do{
                if let arr =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [Dictionary<String, Any>]{
                    for dict in arr
                    {
                        let info = TractorInfo(info:dict)
                        responseArr.append(info)
                    }
                    status = true
                }
            }
            catch{
                print(error)
                status = false
            }
            self.tractorList = responseArr
            handler(status, responseArr)
        })
    }
    
    func createTractorSearchRequest(_ searchInfo: TractorSearchInfo) -> String{
        
        var requestStr = "radius=\(searchInfo.radius)&lat=\(searchInfo.latitude)&lon=\(searchInfo.longitude)"
        
        if (searchInfo.status.count > 0)
        {
            var statusList : [String] = []
            for value in searchInfo.status
            {
                switch value
                {
                    case "Delivered":
                        statusList.append("D")
                    case "In Transit":
                        statusList.append("P")
                    default:
                        break
                }
            }
            let joined = statusList.joined(separator: ", ")
            
            requestStr.append("&status=\(joined.encodeString())")
        }
        
        if searchInfo.trailerType.count > 0
        {
            requestStr.append("&trailerType=\(searchInfo.trailerType.encodeString())")
        }
        
        if searchInfo.tractorType.count > 0
        {
            let joinedStr = searchInfo.tractorType.joined(separator: ",")
            requestStr.append("&tractorType=\(joinedStr.encodeString())")
        }
        
        if searchInfo.hazmat
        {
            requestStr.append("&hazmat=Y")
        }
        
        if searchInfo.loaded
        {
            requestStr.append("&loaded=Y")
        }
        
        return requestStr
    }
    
    func requestToSearchTrailerType(_ search: String, completionHandler handler: @escaping ( Bool, [TrailerInfo]?) -> () )
    {
        let service: String =  "trailer/service/lookup?searchStr=\(search)"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var responseArr = [TrailerInfo]()
            var status : Bool = false
            
            if error != nil {
                handler(status, nil)
                return
            }
            
            do{
                if let arr =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [Dictionary<String, Any>]{
                    for dict in arr
                    {
                        let info = TrailerInfo(info:dict)
                        responseArr.append(info)
                    }
                    status = true
                }
            }
            catch{
                print(error)
                status = false
            }
            handler(status, responseArr)
        })
    }
    
    func requestToSearchTerminal(_ search: String, completionHandler handler: @escaping ( Bool, [String]?) -> () )
    {
        let service: String =  "terminal/service/lookup?searchStr=\(search)"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            var responseArr = [String]()
            var status : Bool = false
            
            if (error != nil)
            {
                handler(status, nil)
                return
            }
            do {
                if let array =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [String]{
                    responseArr.append(contentsOf: array)
                    status = true
                }
            }
            catch{
                print(error)
                status = false
            }
            handler(status, responseArr)
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
        for _ in 1...20
        {
            radiusList.append(String(value))
            value += 25
        }
        return radiusList
    }
    
    func fetchFilterDefaultValues() -> TractorSearchInfo?
    {
        var dict = AppPrefData.sharedInstance.searchDict
        if dict == nil || (dict?.count)! < 0 {
            dict = UIUtils.parsePlist(ofName: "TractorFilter") as? Dictionary <String,Any>
        }
        let searchInfo = TractorSearchInfo(info: dict!)
        return searchInfo
    }
    
}
