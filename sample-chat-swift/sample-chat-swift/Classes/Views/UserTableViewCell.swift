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
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        let markerColor = self.colorMarker.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        self.colorMarker.backgroundColor = markerColor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
        let markerColor = self.colorMarker.backgroundColor
        
        super.setHighlighted(highlighted, animated: animated)
        
        self.colorMarker.backgroundColor = markerColor
    }

}
