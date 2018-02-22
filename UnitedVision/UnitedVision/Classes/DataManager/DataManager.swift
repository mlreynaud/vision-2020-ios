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

    fileprivate override init() {
        let locationManager = LocationManager.sharedInstance
        locationManager.initializeLocationManager()
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
    
    func requestToFetchTractorLocations (completionHandler handler: @escaping ( Bool, [LocationInfo]?) -> () ) {
        
        let service: String = "location/service/active"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var list = [LocationInfo]()

            do {
                let outerJSON = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! String
                let array =  try! JSONSerialization.jsonObject(with: outerJSON.data(using: .utf8)!, options: .allowFragments) as! NSArray

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
        let service: String =  "tractor/service/search?radius=100&city=Lafayette&state=LA&zip=70508"
        
        let request: URLRequest = WebServiceManager.getRequest(service) as URLRequest
        WebServiceManager.sharedInstance.sendRequest(request, completionHandler: {(data, error) in
            
            var list = [TractorInfo]()

            do {
                
                guard   let outerJSON : String = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as? String,
                     outerJSON.count != 0,
                    let array =  try! JSONSerialization.jsonObject(with: outerJSON.data(using: .utf8)!, options: .allowFragments) as? NSArray
                    else {
                        handler(false, nil)
                        return
                    }
                
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

}
