//
//  OpponentCollectionViewCell.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class OpponentCollectionViewCell: UICollectionViewCell {
    
    weak var videoView: UIView? {
        willSet {
            if self.videoView != newValue {
                
                self.videoView?.removeFromSuperview()
                self.videoView = newValue
                self.videoView?.frame = bounds
                containerView.addSubview(self.videoView!)
            }
        }
    }
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    var connectionState: QBRTCConnectionState?
    
    var name: String? {
        willSet {
            if !(self.name == newValue) {
                self.name = newValue
                nameLabel.text = newValue
                nameView.isHidden = false
            }
        }
    }
    
    var nameColor: UIColor? {
        willSet {
            if !(self.nameColor == newValue) {
                self.nameColor = newValue
                nameView.backgroundColor = self.nameColor
            }
        }
    }
    
    var isMuted: Bool? {
        didSet {
            muteButton.isSelected = isMuted!
        }
    }
    
    var bitrate: Double = 0.0
    
    let unmutedImage: UIImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
    let mutedImage: UIImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
    
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var muteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.black
        statusLabel.backgroundColor = UIColor(red: 0.9441, green: 0.9441, blue: 0.9441, alpha: 0.350031672297297)
        name = ""
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = true
        isMuted = false
    }
    
    func setConnectionState(_ connectionState: QBRTCConnectionState) {
        
        if self.connectionState != connectionState {
            self.connectionState = connectionState
            
            switch connectionState {
            case .new:
                statusLabel.text = "New"
            case .pending:
                statusLabel.text = "Pending"
            case .connected:
                statusLabel.text = "Connected"
            case .checking, .connecting:
                statusLabel.text = "Connecting"
            case .closed:
                statusLabel.text = "Closed"
            case .hangUp:
                statusLabel.text = "Hung Up"
            case .rejected:
                statusLabel.text = "Rejected"
            case .noAnswer:
                statusLabel.text = "No Answer"
            case .disconnectTimeout:
                statusLabel.text = "Time out"
            case .disconnected:
                statusLabel.text = "Disconnected"
            default:
                break
            }
            muteButton.isHidden = !(connectionState == .connected)
        }
    }
    
    // MARK: Bitrate
    
    func setBitrate(_ bitrate: Double) {
        if self.bitrate != bitrate {
            self.bitrate = bitrate
            statusLabel.text = String(format: "%.0f kbits/sec", bitrate * 1e-3)
        }
    }
    
    // MARK: Mute button
    @IBAction func didPressMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if didPressMuteButton != nil {
            didPressMuteButton!(sender.isSelected)
        }
    }
    
    func isMutedButton() -> Bool {
        return muteButton.isSelected
    }
}
