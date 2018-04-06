//
//  String.swift
//  UnitedVision
//
//  Created by Agilink on 20/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

extension String {
//    var unescaped: String {
//        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
//        var current = self
//        for entity in entities {
//            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
//            let description = String(descriptionCharacters)
//            current = current.replacingOccurrences(of: description, with: entity)
//        }
//        return current
//    }
    
//    var unescaped: String {
//        let entities = ["\0": "\\0",
//                        "\t": "\\t",
//                        "\n": "\\n",
//                        "\r": "\\r",
//                        "\"": "\\\"",
//                        "\'": "\\'",
//                        ]
//
//        return entities
//            .reduce(self) { (string, entity) in
//                string.replacingOccurrences(of: entity.value, with: entity.key)
//            }
//            .replacingOccurrences(of: "\\\\(?!\\\\)", with: "", options: .regularExpression)
//            .replacingOccurrences(of: "\\\\", with: "\\")
//    }
    
    var isValidEmail: Bool? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate! = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func  createAttributedString(subString: String, subStringColor color: UIColor) -> NSAttributedString{
        
        let range = (self as NSString).range(of: subString)
        
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        
        return attributedString
    }
    
    func  createUnderlineString(subString: String, underlineColor color: UIColor) -> NSAttributedString{
        
        let range = (self as NSString).range(of: subString)
        
        let attributedString = NSMutableAttributedString(string: self)
        
        let attributes    = [NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue, NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.underlineColor : UIColor.blue] as [NSAttributedStringKey : Any]
        
        attributedString.addAttributes(attributes, range: range)
        
        return attributedString
    }
    
    func encodeString() -> String{
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        let encodedString = self.addingPercentEncoding( withAllowedCharacters: allowedCharacterSet)
        return encodedString!
    }
}
