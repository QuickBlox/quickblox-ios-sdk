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
    
    func navigationTitleColor(_ titleColor: UIColor, barColor: UIColor? = nil) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barColor == nil ? #colorLiteral(red: 0.08528385311, green: 0.4896093607, blue: 0.9888257384, alpha: 1) : barColor
        appearance.shadowColor = barColor == nil ? #colorLiteral(red: 0.0862745098, green: 0.4901960784, blue: 0.9882352941, alpha: 1) : barColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.shadowImage = barColor == nil ? #imageLiteral(resourceName: "navbar-shadow") : UIImage()
        if barColor != nil {
            appearance.backgroundImage = UIImage()
        }
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
