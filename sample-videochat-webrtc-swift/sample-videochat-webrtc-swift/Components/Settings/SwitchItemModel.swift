//
//  SwitchItemModel.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

class SwitchItemModel: BaseItemModel {
    //MARK: - Properties
    var on = false
    
    //MARK: - Overrides
    override func viewClass() -> AnyClass {
        return SettingSwitchCell.self
    }
}
