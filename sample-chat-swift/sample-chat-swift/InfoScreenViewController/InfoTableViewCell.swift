//
//  InfoTableViewCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
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
