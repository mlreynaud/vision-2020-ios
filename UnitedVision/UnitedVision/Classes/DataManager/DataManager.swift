//
//  DataManager.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import CoreLocation

enum RequestType {
    case ELogin
    case EVerifiyToken
}

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    var userLocation : CLLocationCoordinate2D?
    var locationList : [LocationInfo] = []
    var tractorList : [TractorInfo] = []
    var tractorSearchInfo : TractorSearchInfo?
    
    var userName: String?
    var authToken = String()
    var userType : UserType = .none
    var canAccessTractorSearch: Bool = false
    
    var radius = 50

    var isLogin = false{
        didSet {
            if !isLogin{
                canAccessTractorSearch = false
            }
        }
    }
    
    fileprivate override init() {
        let locationManager = LocationManager.sharedInstance
        locationManager.initializeLocationManager()
        
        let appPref = AppPrefData.sharedInstance
        self.isLogin = appPref.isLogin
        self.authToken = appPref.authToken ?? ""
        self.userName = appPref.userName
        if let dict = appPref.searchDict, dict.count != 0
        {
            self.tractorSearchInfo = TractorSearchInfo(info: dict)
        }
    }
    
    func parseJSONData(_ data: Data?) -> (status: Bool, message: String, count: String, content: Any?){
        
        guard data != nil else {
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
        else{
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
    
    func requestToLoginOrVerifyToken(reqType: RequestType,paramDict: Dictionary<String, String>?, completionHandler handler: @escaping ( Bool, String) -> () ) {
        
        var service = reqType == RequestType.ELogin ? "auth/service/signin" : "auth/service/verifyToken"
        
        if (reqType == RequestType.ELogin) {
            let encodedUserName = (paramDict!["username"] ?? "").encodeString()
            let encodedPassWord = (paramDict!["password"] ?? "").encodeString()
            service += "?username=\(encodedUserName)&password=\(encodedPassWord)"
        }

        do {
            let request: URLRequest = try WebServiceManager.postRequest(service: service, withPostString:"") as URLRequest
            
            WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error)  in
                
                var status : Bool = false
                var errMess = kNetworkErrorMessage
                
                if error != nil || data == nil{
                    handler(status,error?.domain ?? errMess)
                    return
                }
                
                if httpStatus{
                    do{
                        if let jsonDict =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? Dictionary<String, Any>{
                            let userRole = (jsonDict["role"] as? String) ?? ""
                            if (UserType(rawValue: userRole) == nil){
                                self.userType = UserType.none
                            } else {
                                self.userType = UserType(rawValue: userRole)!
                            }
                            self.userName = jsonDict["firstName"] as? String
                            self.canAccessTractorSearch = ((jsonDict["tractorSearch"] as? String) ?? "") == "Y"
                            status = true
                        }
                    }
                    catch{
                        print("\nError - ",error,"\n Response Data - ",data as Any)
                        status = false
                    }
                }
                else {
                    if let responseStr : String = String(data: data! as Data, encoding: .utf8),
                        responseStr.count != 0{
                        errMess = responseStr
                    }
                }
                handler(status,errMess)
            })
        }
        catch {
            print("\(error.localizedDescription)")
            
            handler(false,error.localizedDescription)
        }
    }
    
    func requestToFetchTerminalLocations (completionHandler handler: @escaping ( Bool, [LocationInfo]?) -> () ) {
        
        let service: String = "terminal/service/active"
        
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service) as URLRequest
            WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
                
                var responseArr = [LocationInfo]()
                var status : Bool = false
                
                if error != nil || data == nil {
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
                    print("\nError - ",error,"\n Response Data - ",data as Any)
                    status = false
                }
                self.locationList = responseArr

                handler(status, responseArr)
            })
        }
        catch {
            print("\(error.localizedDescription)")
            
            handler(false,nil)
        }
    }
    
    func requestToSearchTractor(_ info: TractorSearchInfo, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
        let params = self.createTractorSearchRequest(info)
        let service: String =  "tractor/service/search?\(params)"
        
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service) as URLRequest
            WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
                
                var responseArr = [TractorInfo]()
                var status : Bool = false
                
                if error != nil || data == nil {
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
                    print("\nError - ",error,"\n Response Data - ",data as Any)
                    status = false
                }
                self.tractorList = responseArr
                handler(status, responseArr)
            })
        }
        catch {
            print("\(error.localizedDescription)")
            
            handler(false,nil)
        }
    }
    
    func createTractorSearchRequest(_ searchInfo: TractorSearchInfo) -> String{
        
        func remove(str: String, fromList list: [String]) -> [String]{
            var mutList = list
            if mutList.contains(str){
                mutList.remove(at: mutList.index(of: str)!)
            }
            return mutList
        }
        
        var requestStr = "radius=\(searchInfo.radius)&lat=\(searchInfo.latitude)&lon=\(searchInfo.longitude)"
        
        requestStr.append("&status=")
        searchInfo.status = remove(str: "All", fromList: searchInfo.status)
        if (searchInfo.status.count > 0)
        {
            var statusList : [String] = []
            for value in searchInfo.status
            {
                switch value
                {
                    case "Available":
                        statusList.append("D")
                    case "In Transit":
                        statusList.append("P")
                    default:
                        break
                }
            }
            let joined = statusList.map { $0.encodeString() }.joined(separator: "&status=")
            
            requestStr.append("\(joined)")
        }
        
        if searchInfo.trailerTypeId.count > 0
        {
            requestStr.append("&trailerType=\(searchInfo.trailerTypeId.encodeString())")
        }
        
        searchInfo.tractorType = remove(str: "All", fromList: searchInfo.tractorType)

        if searchInfo.tractorType.count > 0 {
            var tractorTypeList = [String]()
            for tractorType in searchInfo.tractorType
            {
                switch tractorType
                {
                case "Hot Shot":
                    tractorTypeList.append("HS")
                case "One Ton":
                    tractorTypeList.append("OTF")
                case "Mini Float":
                    tractorTypeList.append("MF")
                case "Single Axle":
                    tractorTypeList.append("SA")
                case "Tandem":
                    tractorTypeList.append("TAN")
                default:
                    break
                }
            }
            let joinedStr = tractorTypeList.map { $0.encodeString() }.joined(separator: "&tractorTypes=")
            requestStr.append("&tractorTypes=\(joinedStr)")
        }
        if searchInfo.terminalId.count > 0{
            requestStr.append("&terminalId=\(searchInfo.terminalId.encodeString())")
        }
        
        if searchInfo.hazmat{
            requestStr.append("&hazmat=Y")
        }
        
        if searchInfo.loaded{
            requestStr.append("&loaded=Y")
        }
        
        return requestStr
    }
    
    func requestToSearchTrailerType(_ search: String, completionHandler handler: @escaping ( Bool, [TrailerInfo]?) -> () )
    {
        let service: String =  "trailer/service/lookup?searchStr=\(search.encodeString())"
        
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service) as URLRequest
            WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
                
                var responseArr = [TrailerInfo]()
                var status : Bool = false
                
                if error != nil || data == nil {
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
                    print("\nError - ",error,"\n Response Data - ",data as Any)
                    status = false
                }
                handler(status, responseArr)
            })
        }
        catch {
            print("\(error.localizedDescription)")
            handler(false, nil)
        }
    }
    
    func requestToSearchTerminal(_ search: String, completionHandler handler: @escaping ( Bool, [String]?) -> () )
    {
        let service: String =  "terminal/service/lookup?searchStr=\(search.encodeString())"
        
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service) as URLRequest
            WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
                var responseArr = [String]()
                var status : Bool = false
                
                if (error != nil || data == nil)
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
                    print("\nError - ",error,"\n Response Data - ",data as Any)
                    status = false
                }
                handler(status, responseArr)
            })
        }
        catch {
            print("\(error.localizedDescription)")
            handler(false, nil)
        }
    }
    
    func addNewCallLog(_ tractorId: String,userId: String) {
        //http://uv.agilink.net/api2/tractor/service/callLog/?tractorId=1&userId=test
        let service: String =  "tractor/service/callLog?tractorId=\(tractorId)&userId=\(userId)"
        do {
            let request: URLRequest = try WebServiceManager.postRequest(service: service, withPostDict: Dictionary<String,Any>()) as URLRequest
            
            WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
                if error != nil || data == nil{
                    print(error as Any)
                    return
                }
                guard  let responseStr : String = String(data: data! as Data, encoding: .utf8),
                    responseStr == "Call was successfully logged."
                    else {
                        print(data as Any)
                        return
                }
            }
        }
        catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func fetchContactList(completionHandler handler: @escaping ( Bool, [Dictionary<String, Any>]?,Error?) -> ()) {
        let service: String =  "content/service/contacts"
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service)
            WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
                var responseArr = [Dictionary<String, Any>]()
                var status : Bool = false
                
                if (error != nil || data == nil)
                {
                    handler(status, nil, error)
                    return
                }
                do {
                    if let array =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [Dictionary<String, Any>]{
                        responseArr.append(contentsOf: array)
                        status = true
                    }
                }
                catch{
                    print("\nError - ",error,"\n Response Data - ",data as Any)
                    status = false
                }
                handler(status, responseArr, error)
            }
        }
        catch {
            print("\(error.localizedDescription)")
            handler(false, nil, error)
        }
    }
    
    func getHomeContent(completionHandler handler: @escaping (Bool,String?,Error?) -> ()){
        let service: String =  "content/service/home"
        do {
            let request: URLRequest = try WebServiceManager.getRequest(service)
            WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
                var responseStr:String?
                var status : Bool = false
                
                if (error != nil || data == nil)
                {
                    handler(status, nil, error)
                    return
                }
                if let respStr = String(data: data!, encoding: String.Encoding.utf8){
                    responseStr = respStr.replacingOccurrences(of: "\"", with: "")
                    status = true
                    print(responseStr as Any)
                }
                handler(status, responseStr, error)
            }
        }
        catch {
            print("\(error.localizedDescription)")
            handler(false, nil, error)
        }
    }
    
    func performRegistrationWith(paramDict: Dictionary<String, Any>, completionHandler handler: @escaping (Bool,String?,Error?) -> ()){
        var service: String =  "registration/service/register?"
        var paramString = String()
        paramString += paramDict.map { (k,v)  in "\(k)=\(v)" }.joined(separator: "&")
        paramString = paramString.replacingOccurrences(of:" ", with:"%20")
        service.append(paramString)
        
        do {
            let request: URLRequest = try WebServiceManager.postRequest(service: service, withPostString: "") as URLRequest
            WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
                var responseStr:String?
                var status : Bool = false
                
                if (error != nil || data == nil)
                {
                    handler(status, nil, error)
                    return
                }
                if let respStr = String(data: data!, encoding: String.Encoding.utf8){
                    responseStr = respStr.replacingOccurrences(of: "\"", with: "")
                    status = true
                    print(responseStr as Any)
                }
                handler(status, responseStr, error)
            }
        }
        catch {
            print("\(error.localizedDescription)")
            handler(false, nil, error)
        }
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
    
    func returnFilterValues() -> TractorSearchInfo{
        var tsInfo = DataManager.sharedInstance.tractorSearchInfo
        if tsInfo == nil {
            tsInfo = DataManager.sharedInstance.fetchFilterDefaultValues()
            DataManager.sharedInstance.tractorSearchInfo = tsInfo
        }
        return tsInfo?.copy() as! TractorSearchInfo
    }
    
    func fetchFilterDefaultValues() -> TractorSearchInfo?
    {
        var dict = AppPrefData.sharedInstance.searchDict
        if dict == nil || (dict?.count)! == 0 {
            dict = UIUtils.parsePlist(ofName: "TractorFilter") as? Dictionary <String,Any>
        }
        let searchInfo = TractorSearchInfo(info: dict!)
        return searchInfo
    }
    
}
