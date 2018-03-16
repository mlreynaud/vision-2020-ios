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
    
    init(info : Dictionary<String, Any>)
    {
        title = (info["title"] as? String) ?? ""
        detail = (info["detail"] as? String) ?? ""
        mobile = (info["Mobile"] as? String) ?? ""
        email = (info["Email"] as? String) ?? ""
    }

}
