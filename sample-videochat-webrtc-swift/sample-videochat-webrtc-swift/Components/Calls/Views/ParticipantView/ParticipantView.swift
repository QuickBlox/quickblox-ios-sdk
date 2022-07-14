//
//  ParticipantView.swift
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

class ParticipantView: UIView {
    
    //MARK: - IBOutlets
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var callingInfoLabelHeightConstraint: NSLayoutConstraint!

    
    //MARK: - Properties
    var name = "" {
        didSet {
            nameLabel.text = name
            userAvatarLabel.text = String(name.capitalized.first ?? Character("Q"))
        }
    }
    
    var isCallingInfo = true {
        didSet {
            if isCallingInfo == false {
                callingInfoLabelHeightConstraint.constant = 0.0
            } else {
                callingInfoLabelHeightConstraint.constant = 28.0
            }
        }
    }
    
    var ID: UInt = 0 {
        didSet {
            userAvatarLabel.backgroundColor = ID.generateColor()
        }
    }
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .connected:
                stateLabel.text = ""
                callingInfoLabelHeightConstraint.constant = 0.0
                stateLabel.isHidden = true
            case .closed:
                stateLabel.text = "Closed"
                setupHiddenViews()
            case .failed:
                stateLabel.text = "Failed"
                setupHiddenViews()
            case .hangUp:
                stateLabel.text = "Hung Up"
                setupHiddenViews()
            case .rejected:
                stateLabel.text = "Rejected"
                setupHiddenViews()
            case .noAnswer:
                stateLabel.text = "No Answer"
                setupHiddenViews()
            case .disconnectTimeout:
                stateLabel.text = "Time out"
                setupHiddenViews()
            case .disconnected:
                stateLabel.text = "Disconnected"
                setupHiddenViews()
            default: stateLabel.text = ""
            }
        }
    }
    
    //MARK - Setup
    func setupViews() {
        backgroundColor = .clear
        containerView.backgroundColor = #colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1)
        userAvatarLabel.setRoundedLabel(cornerRadius: 30.0)
        userAvatarImageView.setRoundedView(cornerRadius: 30.0)
        userAvatarImageView.isHidden = true
        nameLabelCenterXConstraint.constant = 0.0
        callingInfoLabelHeightConstraint.constant = 28.0
    }
    
    func setupHiddenViews() {
        callingInfoLabelHeightConstraint.constant = 0.0
        stateLabel.isHidden = false
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
}
