//
//  SettingSliderCell.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class SettingSliderCell: BaseSettingsCell {
    
    @IBOutlet private weak var maxLabel: UILabel!
    @IBOutlet private weak var minLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    
    func setModel(_ model: SliderItemModel?) {
        
        self.model = model
        
        if let aValue = model?.currentValue {
            label.text = String(format: "%tu", aValue)
        }
        if let aValue = model?.maxValue {
            maxLabel.text = String(format: "%tu", aValue)
        }
        if let aValue = model?.minValue {
            minLabel.text = String(format: "%tu", aValue)
        }
        slider.minimumValue = Float(model?.minValue ?? Int(0.0))
        slider.maximumValue = Float(model?.maxValue ?? Int(0.0))
        slider.value = Float(model?.currentValue ?? UInt(0))
        
        let isEnabled = !(model?.isDisabled)!
        slider.isEnabled = isEnabled
        maxLabel.isEnabled = isEnabled
        minLabel.isEnabled = isEnabled
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        
        let model = self.model as? SliderItemModel
        model?.currentValue = UInt(sender.value)
        if let aValue = model?.currentValue {
            label.text = String(format: "%tu", aValue)
        }
    }
}
