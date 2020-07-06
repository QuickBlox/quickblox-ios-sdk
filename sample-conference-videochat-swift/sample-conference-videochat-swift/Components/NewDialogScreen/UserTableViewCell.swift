//
//  UserTableViewCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 12/26/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

//protocol UserCellDelegate: class {
//    func didTapMuteButton(_ userCell: UserTableViewCell)
//}

struct UserCellConstant {
    static let reuseIdentifier =  "UserTableViewCell"
}

class UserTableViewCell: UITableViewCell {
    
    //MARK: - Properties
//    weak var delegate: UserCellDelegate?
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    
    var userColor: UIColor? {
        didSet {
            userAvatarLabel.backgroundColor = userColor
        }
    }
    
    let unmutedImage = UIImage(named: "mute_opponent")!
    let mutedImage = UIImage(named: "unmute_opponent")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatarImageView.isHidden = true
        userAvatarLabel.isHidden = false
        muteButton.isHidden = true
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isSelected = false
        userAvatarLabel.setRoundedLabel(cornerRadius: 20.0)
        contentView.backgroundColor = .clear
        checkBoxView.backgroundColor = .clear
        checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                 borderWidth: 1.0,
                                                 borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
    }
    
    @IBAction func didTapMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didPressMuteButton?(sender.isSelected)
//        delegate?.didTapMuteButton(self)
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
