//
//  SliderItemModel.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

class SliderItemModel: BaseItemModel {
    //MARK: - Properties
    var minLabel = ""
    var maxLabel = ""
    var maxValue: Int = 0
    var currentValue: UInt = 0
    var minValue: Int = 0
    var isDisabled = false
    
    //MARK: - Overrides
    override func viewClass() -> AnyClass {
        return SettingSliderCell.self
    }
}
