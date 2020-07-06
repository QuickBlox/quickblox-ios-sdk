//
//  StreamNotificeView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 5/12/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

protocol StreamNotificeViewDelegate: class {
    func streamViewDidJoinToConference(_ streamView: StreamNotificeView)
}

class StreamNotificeView: UIView {
    
    //MARK: - Properties
    weak var delegate: StreamNotificeViewDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet weak var streamInfoLabel: UILabel!
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinButton.layer.cornerRadius = 4.0
        layer.applyShadow(color: #colorLiteral(red: 0.6980392157, green: 0.7803921569, blue: 0.9333333333, alpha: 1), alpha: 0.49, y: 3.0, blur: 39.0)
    }
    
    // MARK: - Actions
    @IBAction func didTapJoinButton(_ sender: UIButton) {
        delegate?.streamViewDidJoinToConference(self)
    }
}
