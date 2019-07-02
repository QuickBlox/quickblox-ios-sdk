//
//  UserTableViewCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var checkView: CheckView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    
    //MARK: - Properties
    var fullName: String? {
        didSet {
            fullNameLabel.text = fullName
        }
    }
    
    var check: Bool? {
        didSet {
            checkView.check = check
        }
    }
    
    var userImage: UIImage? {
        didSet {
            userImageView.image = userImage
        }
    }
}
