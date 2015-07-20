//
//  UserTableViewCell.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet private weak var colorMarker: CornerView!
    @IBOutlet private weak var userDescriptionLabel: UILabel!
    
    var user: QBUUser?
    var dialogID = ""
    
    var userDescription:String! {
        didSet {
            self.userDescriptionLabel.text = userDescription
        }
    }
    
    func setColorMarkerText(text: String, color: UIColor){
        self.colorMarker.backgroundColor = color
        self.colorMarker.title = text
    }

}
