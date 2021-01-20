//
//  MenuActionCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 11/22/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct MenuActionCellConstant {
   static let reuseIdentifier =  "MenuActionCell"
}

class MenuActionCell: UITableViewCell {

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
