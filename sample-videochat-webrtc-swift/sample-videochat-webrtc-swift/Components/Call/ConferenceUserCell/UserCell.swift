//
//  ConferenceUserCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class UserCell: UICollectionViewCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bitrateLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Properties
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            
            containerView.insertSubview(view, at: 0)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }
    
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .new: statusLabel.text = "New"
            case .pending: statusLabel.text = "Pending"
            case .connected: statusLabel.text = "Connected"
            case .closed: statusLabel.text = "Closed"
            case .failed: statusLabel.text = "Failed"
            case .hangUp: statusLabel.text = "Hung Up"
            case .rejected: statusLabel.text = "Rejected"
            case .noAnswer: statusLabel.text = "No Answer"
            case .disconnectTimeout: statusLabel.text = "Time out"
            case .disconnected: statusLabel.text = "Disconnected"
            case .unknown: statusLabel.text = ""
            default: statusLabel.text = ""
            }
            muteButton.isHidden = !(connectionState == .connected)
        }
    }
    
    var name = "" {
        didSet {
            nameLabel.text = name
            nameView.isHidden = name.isEmpty
            nameView.backgroundColor = PlaceholderGenerator.color(index: name.count)
            muteButton.isHidden = name.isEmpty
        }
    }
    
    var bitrate: Double = 0.0 {
        didSet {
            bitrateLabel.text = String(format: "%.0f kbits/sec", bitrate * 1e-3)
        }
    }
    
    let unmutedImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
    let mutedImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        bitrateLabel.backgroundColor = UIColor(red: 0.9441, green: 0.9441, blue: 0.9441, alpha: 0.350031672297297)
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = true
        muteButton.isSelected = false
    }
    
    //MARK: - Actions
    @IBAction func didPressMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didPressMuteButton?(sender.isSelected)
    }
}
