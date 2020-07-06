//
//  ReuseIdentifierProtocol.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 23.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

public protocol ReuseIdentifierProtocol: class {
    //Get identifier from class
    static var defaultReuseIdentifier: String { get }
}

public extension ReuseIdentifierProtocol where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
