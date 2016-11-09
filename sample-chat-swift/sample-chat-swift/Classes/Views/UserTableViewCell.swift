//
//  UserTableViewCell.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var colorMarker: CornerView!
    @IBOutlet fileprivate weak var userDescriptionLabel: UILabel!
    
    var user: QBUUser?
    var dialogID = ""
    
    var userDescription:String! {
        didSet {
            self.userDescriptionLabel.text = userDescription
        }
    }
    
    func setColorMarkerText(_ text: String, color: UIColor){
        self.colorMarker.backgroundColor = color
        self.colorMarker.title = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let markerColor = self.colorMarker.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        self.colorMarker.backgroundColor = markerColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let markerColor = self.colorMarker.backgroundColor
        
        super.setHighlighted(highlighted, animated: animated)
        
        self.colorMarker.backgroundColor = markerColor
    }
}
