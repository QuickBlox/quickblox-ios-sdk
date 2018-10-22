//
//  SliderItemModel.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

class SliderItemModel: BaseItemModel {
    var minLabel = ""
    var maxLabel = ""
    var maxValue: Int = 0
    var currentValue: UInt = 0
    var minValue: Int = 0
    var isDisabled = false
    
    override func viewClass() -> AnyClass {
        
        return SettingSliderCell.self
    }
}
