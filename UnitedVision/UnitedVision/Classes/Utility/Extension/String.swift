//
//  String.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 20/02/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
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
}
