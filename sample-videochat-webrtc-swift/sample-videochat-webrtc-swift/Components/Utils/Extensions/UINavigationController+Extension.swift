//
//  UINavigationController+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 24.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

extension UINavigationController {
    func transparent(_ enabled : Bool) {
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = enabled
    }
}
