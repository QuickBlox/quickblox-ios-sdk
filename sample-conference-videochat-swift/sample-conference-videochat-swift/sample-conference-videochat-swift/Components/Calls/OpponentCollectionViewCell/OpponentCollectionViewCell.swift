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
            if videoView != newValue {
                
                videoView?.removeFromSuperview()
                videoView = newValue
                videoView.frame = bounds
                containerView.addSubview(videoView)
            }
        }
    }
        /**
         *  Mute user block action.
         */
        var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
        var connectionState: QBRTCConnectionState?
        var name = ""
        var nameColor: UIColor?
        var isMuted = false
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
        
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = true
    }
    
    func setName(_ name: String?) {
        
        if !(_name == name) {
            
            _name = name
            nameLabel.text = _name
            nameView.isHidden = _name == nil
        }
    }
    
    func setNameColor(_ nameColor: UIColor?) {
        
        if !(_nameColor == nameColor) {
            
            _nameColor = nameColor
            nameView.backgroundColor = nameColor
        }
    }
}
