//
//  BaseItemModel.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class BaseItemModel {
    //MARK: - Properties
    var title = ""
    var data: Any?
    
    //MARK: - Public Methods
    func viewClass() -> AnyClass {
        return SettingCell.self
    }
}
