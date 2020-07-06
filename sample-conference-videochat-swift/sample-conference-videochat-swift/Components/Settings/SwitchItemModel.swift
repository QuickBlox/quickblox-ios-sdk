//
//  SwitchItemModel.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 22.10.2018.
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
