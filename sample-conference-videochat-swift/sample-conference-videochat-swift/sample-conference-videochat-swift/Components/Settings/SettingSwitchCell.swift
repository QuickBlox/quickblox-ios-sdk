//
//  SettingSwitchCell.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class SettingSwitchCell: BaseSettingsCell {

    @IBOutlet private weak var switchCtrl: UISwitch!
    var modelSwitch = SwitchItemModel()
    
    override func updateModel(_ model: BaseItemModel) {
        modelSwitch = model as! SwitchItemModel
        switchCtrl.isOn = modelSwitch.on
        label.text = modelSwitch.title
    }
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        modelSwitch.on = sender.isOn
        delegate?.cell(self, didChageModel: modelSwitch)
    }
}
