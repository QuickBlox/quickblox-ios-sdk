//
//  BaseItemModel.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class BaseItemModel {
    var title = ""
    var data: Any?
    
    func viewClass() -> AnyClass {
        return  SettingCell.self
    }
}
