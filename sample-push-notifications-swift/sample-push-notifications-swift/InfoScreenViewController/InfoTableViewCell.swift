//
//  InfoTableViewCell.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 12/30/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var titleInfoLabel: UILabel!
    @IBOutlet weak var descriptInfoLabel: UILabel!
    
    // MARK: - Public Methods
    func applyInfo(model: InfoModel) {
        titleInfoLabel.text = model.title
        descriptInfoLabel.text = model.info
    }
}
