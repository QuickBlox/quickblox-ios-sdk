//
//  ParticipantAudioView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 08.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct ParticipantViewConstant {
    static let stateColor = #colorLiteral(red: 0.700391233, green: 0.7436676621, blue: 0.8309402466, alpha: 1)
}

class ParticipantAudioView: UIView {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var userView: UIView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var callingToLabelHeight: NSLayoutConstraint!

    
    //MARK: - Properties
    var name = "" {
        didSet {
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
            case .rejected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Rejected"
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
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
            default: stateLabel.text = ""
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        containerView.backgroundColor = #colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1)
        userAvatarLabel.setRoundedLabel(cornerRadius: 30.0)
        userAvatarImageView.setRoundedView(cornerRadius: 30.0)
        userAvatarImageView.isHidden = true
        nameLabelCenterXConstraint.constant = 0.0
        callingToLabelHeight.constant = 28.0
    }
}
