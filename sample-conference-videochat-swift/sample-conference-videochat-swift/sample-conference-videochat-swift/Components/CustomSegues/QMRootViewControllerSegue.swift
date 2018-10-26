//
//  QMRootViewControllerSegue.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class QMRootViewControllerSegue: UIStoryboardSegue {
    override func perform() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.window?.rootViewController = destination
    }
}
