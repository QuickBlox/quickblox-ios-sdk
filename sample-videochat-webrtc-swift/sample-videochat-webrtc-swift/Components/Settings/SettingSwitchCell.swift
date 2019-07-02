//
//  SettingSwitchCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class SettingSwitchCell: BaseSettingsCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var switchCtrl: UISwitch!
    //MARK: - Properties
    var modelSwitch = SwitchItemModel()
    
    //MARK: - Overrides
    override func updateModel(_ model: BaseItemModel) {
        guard let model = model as? SwitchItemModel else { return }
        modelSwitch = model
        switchCtrl.isOn = modelSwitch.on
        label.text = modelSwitch.title
    }
    
    //MARK: - Actions
    @IBAction func valueChanged(_ sender: UISwitch) {
        modelSwitch.on = sender.isOn
        delegate?.cell(self, didChageModel: modelSwitch)
    }
}
