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

let kUrlFormatnFailedMsg = "Url formation got failed.Please try again shortly."

let kUrlFormatnFailErr = NSError(domain: kUrlFormatnFailedMsg, code: 101, userInfo: nil)

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    var userLocation: CLLocationCoordinate2D?
    var locationList: [LocationInfo] = []
    var tractorList: [TractorInfo] = []
    var tractorSearchInfo: TractorSearchInfo?
    var loadBoardSearchInfo: LoadBoardSearchInfo?
    
    var userName: String?
    var authToken = String()
    var userType : UserType = .none
    var canAccessTractorSearch: Bool = false
    var canAccessLoadBoard: Bool = false
    
    var radius = 50

    var isLogin = false{
        didSet {
            if !isLogin{
                canAccessTractorSearch = false
                canAccessLoadBoard = false
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
        
        if let tractorSearchDict = appPref.tractorSearchDict, tractorSearchDict.count != 0{
            self.tractorSearchInfo = TractorSearchInfo(info: tractorSearchDict)
        }
        
        if let loadBoardSearchDict = appPref.loadBoardSearchDict, loadBoardSearchDict.count != 0{
            self.loadBoardSearchInfo = LoadBoardSearchInfo(info: loadBoardSearchDict)
        }
    }

    func requestToLoginOrVerifyToken(reqType: RequestType,paramDict: Dictionary<String, String>?, completionHandler handler: @escaping ( Bool, String) -> () ) {
        
        var service = reqType == RequestType.ELogin ? "auth/service/signin" : "auth/service/verifyToken"
        
        if (reqType == RequestType.ELogin) {
            let encodedUserName = (paramDict!["username"] ?? "").encodeString()
            let encodedPassWord = (paramDict!["password"] ?? "").encodeString()
            service += "?username=\(encodedUserName)&password=\(encodedPassWord)"
        }
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(false, kUrlFormatnFailedMsg)
            return
        }
        
        let request = WebServiceManager.postRequest(url: url, withPostString: "")
        
        WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error)  in
            
            var status : Bool = false
            var errMess = kNetworkErrorMessage
            
            if error != nil || data == nil{
                handler(status,error?.localizedDescription ?? error?.domain ?? errMess)
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
                        self.canAccessLoadBoard = ((jsonDict["loadBoard"] as? String) ?? "") == "Y"
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
    
    func requestToFetchTerminalLocations (completionHandler handler: @escaping ( Bool, [LocationInfo]?) -> () ) {
        
        var responseArr = [LocationInfo]()
        var status : Bool = false
        
        let service: String = "terminal/service/active"
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr)
            return
        }
        
        let request = WebServiceManager.getRequest(url: url)
        
        WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
            
            
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
    
    func requestToSearchTractor(_ info: TractorSearchInfo, completionHandler handler: @escaping ( Bool, [TractorInfo]?) -> () )
    {
        var responseArr = [TractorInfo]()
        var status : Bool = false
        
        let params = self.createTractorSearchRequest(info)
        let service: String =  "tractor/service/search?\(params)"
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr)
            return
        }
        
        let request =  WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
            
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
        var responseArr = [TrailerInfo]()
        var status : Bool = false
        
        let service: String =  "trailer/service/lookup?searchStr=\(search.encodeString())"
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr)
            return
        }
        
        let request = WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
            
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
    
    func requestToSearchTerminal(_ search: String, completionHandler handler: @escaping ( Bool, [String]?) -> () )
    {
        var responseArr = [String]()
        var status : Bool = false
        
        let service: String =  "terminal/service/lookup?searchStr=\(search.encodeString())"
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr)
            return
        }
        let request = WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request, completionHandler: {(httpStatus, data, error) in
            
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
    
    func addNewCallLog(_ tractorId: String,userId: String) {
        let service: String =  "tractor/service/callLog?tractorId=\(tractorId)&userId=\(userId)"
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            print(kUrlFormatnFailedMsg)
            return
        }
        let request = WebServiceManager.postRequest(url: url, withPostDict: Dictionary<String, Any>())
        
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
    
    func fetchContactList(completionHandler handler: @escaping ( Bool, [Dictionary<String, Any>]?,NSError?) -> ()) {
        var responseArr = [Dictionary<String, Any>]()
        var status : Bool = false
        let service: String =  "content/service/contacts"
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr, kUrlFormatnFailErr)
            return
        }
        
        let request =  WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
            
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
    
    func getHomeContent(completionHandler handler: @escaping (Bool,String?,NSError?) -> ()){
        var responseStr:String?
        var status : Bool = false
        let service: String =  "content/service/home"
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseStr, kUrlFormatnFailErr)
            return
        }
        let request = WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
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
    
    func getLoadBoardContent(info: LoadBoardSearchInfo, completionHandler handler: @escaping (Bool,[Any]?,Error?) -> ()){
        var responseArr = [LoadBoardInfo]()
        var status : Bool = false
        
        let params = self.createLoadBoardSearchRequest(info)
        let service: String =  "order/service/loadboard?\(params)"
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseArr, kUrlFormatnFailErr)
            return
        }
        let request = WebServiceManager.getRequest(url: url)
        WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
            
            if (error != nil || data == nil)
            {
                handler(status, nil, error)
                return
            }
            do {
                if let array =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions()) as? [Dictionary<String, Any>]{
                    for loadBoardDict in array{
                        let loadBoardInfo = LoadBoardInfo(loadBoardDict: loadBoardDict)
                        responseArr.append(loadBoardInfo)
                    }
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
    
    func createLoadBoardSearchRequest(_ searchInfo: LoadBoardSearchInfo) -> String{
        func remove(str: String, fromList list: [String]) -> [String]{
            var mutList = list
            if mutList.contains(str){
                mutList.remove(at: mutList.index(of: str)!)
            }
            return mutList
        }
        var requestStr = String()
        if !searchInfo.originCity.isBlank(){
            requestStr.append("originCity=" + "\(searchInfo.originCity) \(searchInfo.originStateAbbrev)".encodeString())
            requestStr.append("&")
        }
        if !searchInfo.destCity.isBlank(){
            requestStr.append("destCity=" + "\(searchInfo.destCity) \(searchInfo.destStateAbbrev)".encodeString())
        }
        
        if searchInfo.trailerTypeId.count > 0{
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
            requestStr.append("&terminal=\(searchInfo.terminalId.encodeString())")
        }
        if searchInfo.hazmat{
            requestStr.append("&hazmat=Y")
        }
        return requestStr
    }
    
    func performRegistrationWith(paramDict: Dictionary<String, Any>, completionHandler handler: @escaping (Bool,String?,Error?) -> ()){
        var responseStr:String?
        var status : Bool = false
        
        var service: String =  "registration/service/register?"
        var paramString = String()
        paramString += paramDict.map { (k,v)  in "\(k)=\(v)" }.joined(separator: "&")
        paramString = paramString.replacingOccurrences(of:" ", with:"%20")
        service.append(paramString)
        
        let urlString = kServerUrl + service
        guard let url = URL(string: urlString) else {
            handler(status, responseStr, kUrlFormatnFailErr)
            return
        }
        
        let request = WebServiceManager.postRequest(url: url, withPostString: "")
        WebServiceManager.sendRequest(request) { (httpStatus, data, error) in
            
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
    
    func getRadiusList() -> [String]
    {
        var radiusList = [String]()
        var value = 25
        for _ in 1...20{
            radiusList.append(String(value))
            value += 25
        }
        return radiusList
    }
    
    func returnTractorSearchFilterValues() -> TractorSearchInfo{
        var tsInfo = DataManager.sharedInstance.tractorSearchInfo
        if tsInfo == nil {
            tsInfo = DataManager.sharedInstance.fetchTractorSearchFilterDefaultValues()
            DataManager.sharedInstance.tractorSearchInfo = tsInfo
        }
        return tsInfo?.copy() as! TractorSearchInfo
    }
    
    func fetchTractorSearchFilterDefaultValues() -> TractorSearchInfo?{
        var dict = AppPrefData.sharedInstance.tractorSearchDict
        if dict == nil || (dict?.count)! == 0 {
            dict = UIUtils.parsePlist(ofName: "TractorFilter") as? Dictionary <String,Any>
        }
        let searchInfo = TractorSearchInfo(info: dict!)
        return searchInfo
    }
    
    func returnLoadBoardSearchFilterValues() -> LoadBoardSearchInfo{
        var lbSearchInfo = DataManager.sharedInstance.loadBoardSearchInfo
        if lbSearchInfo == nil {
            lbSearchInfo = DataManager.sharedInstance.fetchLoadBoardSearchFilterDefaultValues()
            DataManager.sharedInstance.loadBoardSearchInfo = lbSearchInfo
        }
        return lbSearchInfo?.copy() as! LoadBoardSearchInfo
    }
    
    func fetchLoadBoardSearchFilterDefaultValues() -> LoadBoardSearchInfo?{
        var lbSearchDict = AppPrefData.sharedInstance.loadBoardSearchDict
        if lbSearchDict == nil || (lbSearchDict?.count)! == 0 {
            lbSearchDict = UIUtils.parsePlist(ofName: "LoadBoardFilter") as? Dictionary <String,Any>
        }
        let lbSearchInfo = LoadBoardSearchInfo(info: lbSearchDict!)
        return lbSearchInfo
    }
}
