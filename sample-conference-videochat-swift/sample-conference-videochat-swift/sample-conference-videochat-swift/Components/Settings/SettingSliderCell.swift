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
    
    override func updateModel(_ model: BaseItemModel) {
        let modelSlider = model as! SliderItemModel
        
        label.text = String(format: "%tu", modelSlider.currentValue)
        maxLabel.text = String(format: "%tu", modelSlider.maxValue)
        minLabel.text = String(format: "%tu", modelSlider.minValue)
        
        slider.minimumValue = Float(modelSlider.minValue)
        slider.maximumValue = Float(modelSlider.maxValue)
        slider.value = Float(modelSlider.currentValue)
        
        let isEnabled = !modelSlider.isDisabled
        slider.isEnabled = isEnabled
        maxLabel.isEnabled = isEnabled
        minLabel.isEnabled = isEnabled
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        
        let model = self.model as? SliderItemModel
        debugPrint("sender.value \(sender.value)")
        model?.currentValue = UInt(sender.value)
//        if let aValue = model?.currentValue {
            label.text = String(format: "%tu", UInt(sender.value))
//        }
    }
}
