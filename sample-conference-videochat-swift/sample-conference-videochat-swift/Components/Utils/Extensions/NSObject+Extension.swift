//
//  NSObject+Extension.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

extension NSObject {
    
  class var className: String {
    return String(describing: self)
  }
}
