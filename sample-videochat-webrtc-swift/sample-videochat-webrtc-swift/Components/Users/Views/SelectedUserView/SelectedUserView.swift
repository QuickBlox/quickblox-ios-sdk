//
//  SelectedUserView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 28.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

typealias CancelHandler = ( _ iD: UInt) -> Void

class SelectedUserView: UIView {
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    //MARK: - Properties
    var onCancelTapped: CancelHandler?
    var name = "" {
        didSet {
            nameLabel.text = name
        }
    }
    var userID: UInt = 0
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setRoundBorderEdgeColorView(cornerRadius: 4.0, borderWidth: 1.0, borderColor: #colorLiteral(red: 0.4975875616, green: 0.5540842414, blue: 0.639736414, alpha: 1))
    }

    //MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        onCancelTapped?(userID)
    }
}
