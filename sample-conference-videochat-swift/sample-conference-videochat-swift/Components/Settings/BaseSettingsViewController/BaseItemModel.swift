//
//  BaseItemModel.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class BaseItemModel {
    //MARK: - Properties
    var title = ""
    var data: Any?
    
    //MARK: - Public Methods
    func viewClass() -> AnyClass {
        return  SettingCell.self
    }
}
