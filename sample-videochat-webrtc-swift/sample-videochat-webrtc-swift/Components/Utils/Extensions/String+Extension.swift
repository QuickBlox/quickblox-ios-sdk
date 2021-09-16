//
//  String+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return String(describing: aClass)
    }
    
    func isValid(regexes: [String]) -> Bool {
        if self.isEmpty {
            return false
        }
        for regex in regexes {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: self) == true {
                return true
            }
        }
        return false
    }
}
