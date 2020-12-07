//
//  UIView+Extension.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 26.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String(describing: viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
}
