//
//  ActionMenuCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 14.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

struct MenuActionCellConstant {
   static let reuseIdentifier =  "MenuActionCell"
}

class ActionMenuCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorView.isHidden = true
    }
}
