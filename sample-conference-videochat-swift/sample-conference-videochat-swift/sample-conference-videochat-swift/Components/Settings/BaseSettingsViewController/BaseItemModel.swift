//
//  BaseItemModel.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: class {
    func cell(_ cell: BaseSettingsCell?, didChageModel model: BaseItemModel?)
}

class BaseSettingsCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var model: BaseItemModel?
    weak var delegate: SettingsCellDelegate?
    
    class func identifier() -> String? {
        return NSStringFromClass(BaseSettingsCell.self)
    }
    
    class func nib() -> UINib? {
        return UINib(nibName: self.identifier() ?? "", bundle: nil)
    }
    
    func setModel(_ model: BaseItemModel?) {
        
        self.model = model
        label.text = model?.title
    }
}
