//
//  SelectableUserTableViewCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 9/8/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class SelectableUserTableViewCell: UserTableViewCell {
    
    @IBOutlet weak var checkboxImageView: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.checkboxImageView.image = selected ? UIImage(named: "checkbox_a") : UIImage(named: "checkbox")
    }
}