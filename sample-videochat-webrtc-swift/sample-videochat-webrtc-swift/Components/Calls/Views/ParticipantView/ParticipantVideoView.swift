//
//  ParticipantVideoView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 19.08.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class ParticipantVideoView: UIView {
    
    //MARK: - IBOutlets
    @IBOutlet weak var userNameTopLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var userNameTopView: UIView!
    @IBOutlet private weak var userView: UIView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var callingToLabelHeight: NSLayoutConstraint!
    
    //MARK: - Properties
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            userNameTopView.isHidden = false
            videoContainerView.insertSubview(view, at: 0)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: videoContainerView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: videoContainerView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: videoContainerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor).isActive = true
            view.layoutIfNeeded()
        }
    }
    
    var name = "" {
        didSet {
            userNameTopLabel.text = name
            nameLabel.text = name
            userAvatarLabel.text = String(name.capitalized.first ?? Character("Q"))
        }
    }
    
    override var tag: Int {
        didSet {
            userAvatarLabel.backgroundColor = UInt(tag).generateColor()
        }
    }
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .new, .pending, .unknown: stateLabel.text = ""
            case .connected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = ""
                callingToLabelHeight.constant = 0.0
                stateLabel.isHidden = true
            case .closed:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Closed"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
            case .failed:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Failed"
                callingToLabelHeight.constant = 0.0
                stateLabel.isHidden = false
            case .hangUp:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Hung Up"
                stateLabel.isHidden = false
                videoView?.isHidden = true
                userNameTopView.isHidden = true
            case .rejected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Rejected"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                videoView?.isHidden = true
                userNameTopView.isHidden = true
            case .noAnswer:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "No Answer"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
            case .disconnectTimeout:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Time out"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
            case .disconnected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Disconnected"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                videoView?.isHidden = true
                userNameTopView.isHidden = true
            default: stateLabel.text = ""
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        videoContainerView.backgroundColor = .clear
        containerView.backgroundColor = #colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1)
        userAvatarLabel.setRoundedLabel(cornerRadius: 30.0)
        userAvatarImageView.setRoundedView(cornerRadius: 30.0)
        userAvatarImageView.isHidden = true
        videoContainerView.isHidden = false
        userNameTopView.isHidden = true
        nameLabelCenterXConstraint.constant = 0.0
        callingToLabelHeight.constant = 28.0
    }
}
