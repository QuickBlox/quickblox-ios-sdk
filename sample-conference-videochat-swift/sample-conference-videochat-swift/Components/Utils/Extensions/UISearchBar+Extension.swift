//
//  UISearchBar+Extension.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/9/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UISearchBar {
    var cancelButton : UIButton? {
        if let view = self.subviews.first {
            for subView in view.subviews {
                if let cancelButton = subView as? UIButton {
                    return cancelButton
                }
            }
        }
        return nil
    }
}
