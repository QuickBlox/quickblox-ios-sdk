//
//  String+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

extension String {
  func stringByTrimingWhitespace() -> String {
    let squashed = replacingOccurrences(of: "[ ]+",
                                        with: " ",
                                        options: .regularExpression)
    return squashed.trimmingCharacters(in: .whitespacesAndNewlines)
  }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
        func generateColor() -> UIColor {
            let hash = abs(self.hashValue)
            let colorNum = hash % (256*256*256)                     
            let redColor = colorNum >> 16
            let greenColor = (colorNum & 0x00FF00) >> 8
            let blueColor = (colorNum & 0x0000FF)
            let color = UIColor(red: CGFloat(redColor)/255.0,
                                green: CGFloat(greenColor)/255.0,
                                blue: CGFloat(blueColor)/255.0,
                                alpha: 1.0)
            return color
        }
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
}
