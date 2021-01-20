//
//  RootViewControllerSegue.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class RootViewControllerSegue: UIStoryboardSegue {
    override func perform() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.window?.rootViewController = destination
    }
}
