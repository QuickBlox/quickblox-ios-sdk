//
//  UserTableViewCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var colorMarker: CornerView!
    @IBOutlet fileprivate weak var userDescriptionLabel: UILabel!
    
    var user: QBUUser?
    var dialogID = ""
    
    var userDescription:String! {
        didSet {
            userDescriptionLabel.text = userDescription
        }
    }
    
    func setupColorMarker(_ color: UIColor){
        colorMarker.backgroundColor = color
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let markerColor = colorMarker.backgroundColor
        super.setSelected(selected, animated: animated)
        colorMarker.backgroundColor = markerColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let markerColor = colorMarker.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        colorMarker.backgroundColor = markerColor
    }
}
