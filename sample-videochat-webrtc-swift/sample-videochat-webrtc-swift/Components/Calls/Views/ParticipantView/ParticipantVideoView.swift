//
//  ParticipantVideoView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 19.08.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class ParticipantVideoView: ParticipantView {
    
    //MARK: - IBOutlets
    @IBOutlet weak var userNameTopLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    
    
    //MARK: - Properties
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            userNameTopLabel.isHidden = false
            videoContainerView.insertSubview(view, at: 0)
            videoContainerView.isHidden = false
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: videoContainerView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: videoContainerView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: videoContainerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor).isActive = true
            view.layoutIfNeeded()
        }
    }
    
    override var name: String {
        didSet {
            userNameTopLabel.text = name
            nameLabel.text = name
            userAvatarLabel.text = String(name.capitalized.first ?? Character("Q"))
        }
    }
    
    override var ID: UInt {
        didSet {
            if Profile().ID == ID {
                userNameTopLabel.text = "You"
            }
            userAvatarLabel.backgroundColor = ID.generateColor()
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        userNameTopLabel.isHidden = true
    }
    
    override func setupHiddenViews() {
        callingInfoLabelHeightConstraint.constant = 0.0
        stateLabel.isHidden = false
        videoContainerView.isHidden = true
    }
}
