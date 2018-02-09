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

}
