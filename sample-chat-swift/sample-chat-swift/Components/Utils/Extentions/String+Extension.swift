//
//  String+Extension.swift
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
    
    func stringWidth() -> CGFloat {
        let label = UILabel(frame: .zero)
        label.text = self
        return label.intrinsicContentSize.width
    }
}
