//
//  InfoTableViewCell.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 12/30/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleInfoLabel: UILabel!
    @IBOutlet weak var descriptInfoLabel: UILabel!
    
    func applyInfo(model: InfoModel) {
        titleInfoLabel.text = model.title
        descriptInfoLabel.text = model.info
    }
}
