//
//  BaseSettingsCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: class {
    func cell(_ cell: BaseSettingsCell, didChageModel model: BaseItemModel)
}

class BaseSettingsCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var label: UILabel!
    
    //MARK: - Properties
    var model = BaseItemModel() {
        didSet {
            updateModel(model)
        }
    }
    weak var delegate: SettingsCellDelegate?
    
    //MARK: - Class Methods
    class func identifier() -> String? {
        guard let cellIdentifier = NSStringFromClass(BaseSettingsCell.self).components(separatedBy: ".").last else {
            return nil
        }
        return cellIdentifier
    }
    
    class func nib() -> UINib? {
        return UINib(nibName: NSStringFromClass(BaseSettingsCell.self), bundle: nil)
    }
    
    //MARK: - Public Methods
    func updateModel(_ model: BaseItemModel) {
        label.text = model.title
    }
}

