//
//  UserTableViewCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/26/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct UserCellConstant {
   static let reuseIdentifier =  "UserTableViewCell"
}

class UserTableViewCell: UITableViewCell {

     @IBOutlet weak var userAvatarImageView: UIImageView!
        @IBOutlet weak var userAvatarLabel: UILabel!
        @IBOutlet weak var userNameLabel: UILabel!
        @IBOutlet weak var checkBoxView: UIView!
        @IBOutlet weak var checkBoxImageView: UIImageView!
        
        
        var userColor: UIColor? {
            didSet {
                userAvatarLabel.backgroundColor = userColor
            }
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            userAvatarImageView.isHidden = true
            userAvatarLabel.isHidden = false
            userAvatarLabel.setRoundedLabel(cornerRadius: 20.0)
            contentView.backgroundColor = .clear
            checkBoxView.backgroundColor = .clear
            checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                borderWidth: 1.0,
                                                borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            if self.isSelected == true {
                contentView.backgroundColor = UIColor(red:0.85, green:0.89, blue:0.97, alpha:1)
                
                checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                         borderWidth: 1.0,
                                                         color: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1),
                                                         borderColor: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1))
            } else {
                contentView.backgroundColor = .clear
                
                checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                         borderWidth: 1.0,
                                                         color: .clear,
                                                         borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
            }
            userAvatarLabel.backgroundColor = userColor
        }
        
        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            
            if self.isHighlighted == true {
                contentView.backgroundColor = UIColor(red:0.85, green:0.89, blue:0.97, alpha:1)
                checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                         borderWidth: 1.0,
                                                         color: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1),
                                                         borderColor: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1))
            } else {
                contentView.backgroundColor = .clear
                checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                         borderWidth: 1.0,
                                                         color: .clear,
                                                         borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
            }
            userAvatarLabel.backgroundColor = userColor
        }
    }

