//
//  SettingSliderCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class SettingSliderCell: BaseSettingsCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var maxLabel: UILabel!
    @IBOutlet private weak var minLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    
    //MARK: - Properties
    var modelSlider = SliderItemModel()
    
    //MARK: - Overrides
    override func updateModel(_ model: BaseItemModel) {
        guard let model = model as? SliderItemModel else { return }
        modelSlider = model
        label.text = "\(modelSlider.currentValue)"
        maxLabel.text = "\(modelSlider.maxValue)"
        minLabel.text = "\(modelSlider.minValue)"
        
        slider.minimumValue = Float(modelSlider.minValue)
        slider.maximumValue = Float(modelSlider.maxValue)
        slider.value = Float(modelSlider.currentValue)
        
        let isEnabled = !modelSlider.isDisabled
        slider.isEnabled = isEnabled
        maxLabel.isEnabled = isEnabled
        minLabel.isEnabled = isEnabled
    }
    
    //MARK: - Actions
    @IBAction func valueChanged(_ sender: UISlider) {
        modelSlider.currentValue = UInt(sender.value)
        label.text = "\(UInt(sender.value))"
    }
}
