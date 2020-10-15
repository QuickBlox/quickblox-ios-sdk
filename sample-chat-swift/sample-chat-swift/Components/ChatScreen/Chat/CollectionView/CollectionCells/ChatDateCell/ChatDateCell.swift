//
//  ChatDateCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/3/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatDateCell: ChatCell {
    @IBOutlet weak var dateBackgroundView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.topLabelHeight = 0.0
        defaultLayoutModel.timeLabelHeight = 0.0
        
        return defaultLayoutModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateBackgroundView.setRoundView(cornerRadius: 11)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 15),
            
            dateBackgroundView.topAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -3),
            dateBackgroundView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -16),
            dateBackgroundView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
            dateBackgroundView.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 15),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
