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
    
    func setModel(_ model: SwitchItemModel?) {
        
        super.model = model
        switchCtrl.isOn = model?.on ?? false
    }
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        
        let model = self.model as? SwitchItemModel
        model?.on = sender.isOn
        delegate?.cell(self, didChageModel: self.model)
    }
}
