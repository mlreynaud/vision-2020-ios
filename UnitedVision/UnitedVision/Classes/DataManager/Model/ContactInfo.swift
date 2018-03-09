//
//  ContactInfo.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 09/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit

class ContactInfo: NSObject {
    
    var title: String?
    var detail: String?
    var mobile: String?
    var email: String?
    
    init(info : NSDictionary)
    {
        title = (info.object(forKey: "title") as? String) ?? ""
        detail = (info.object(forKey: "detail") as? String) ?? ""
        mobile = (info.object(forKey: "Mobile") as? String) ?? ""
        email = (info.object(forKey: "Email") as? String) ?? ""
    }

}
