//
//  DialogTableViewCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class DialogTableViewCell: UITableViewCell {

    @IBOutlet weak var dialogLastMessage: UILabel!
    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var dialogTypeImage: UIImageView!
    @IBOutlet weak var unreadMessageCounterLabel: UILabel!
    
    @IBOutlet weak var unreadMessageCounterHolder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.unreadMessageCounterHolder.layer.cornerRadius = 10.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let markerColor = self.unreadMessageCounterHolder.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        self.unreadMessageCounterHolder.backgroundColor = markerColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let markerColor = self.unreadMessageCounterHolder.backgroundColor
        
        super.setHighlighted(highlighted, animated: animated)
        
        self.unreadMessageCounterHolder.backgroundColor = markerColor
    }
}
