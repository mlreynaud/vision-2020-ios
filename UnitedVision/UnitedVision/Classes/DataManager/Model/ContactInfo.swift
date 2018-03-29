//
//  ContactInfo.swift
//  UnitedVision
//
//  Created by Agilink on 09/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class ContactInfo: NSObject {
    
    var name: String?
    var sequence: String?
    var phone: String?
    var email: String?
    
    init(info : Dictionary<String, Any>)
    {
        name = (info["name"] as? String) ?? ""
        sequence = (info["sequence"] as? String) ?? ""
        phone = (info["phone"] as? String) ?? ""
        email = (info["email"] as? String) ?? ""
    }

}
