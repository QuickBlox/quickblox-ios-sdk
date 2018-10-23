//
//  BaseSettingsCell.swift
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
    var model: BaseItemModel? {
        didSet {
            label.text = model?.title
        }
    }
    weak var delegate: SettingsCellDelegate?
    
    class func identifier() -> String? {
        return NSStringFromClass(BaseSettingsCell.self).components(separatedBy: ".").last!
    }
    
    class func nib() -> UINib? {
        return UINib(nibName: NSStringFromClass(BaseSettingsCell.self), bundle: nil)
    }
}
