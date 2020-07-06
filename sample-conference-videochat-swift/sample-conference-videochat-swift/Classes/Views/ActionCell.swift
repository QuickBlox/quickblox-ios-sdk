//
//  ActionCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 26.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

    @IBOutlet weak var actionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
