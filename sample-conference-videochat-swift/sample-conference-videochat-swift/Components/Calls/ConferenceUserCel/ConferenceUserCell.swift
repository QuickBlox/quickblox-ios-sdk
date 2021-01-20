//
//  ConferenceUserCell1.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 17.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

struct ConferenceUserCellConstant {
   static let reuseIdentifier = "ConferenceUserCell"
}

class ConferenceUserCell: UICollectionViewCell {

       //MARK: - IBOutlets
        @IBOutlet private weak var userView: UIView!
        @IBOutlet private weak var userAvatarLabel: UILabel!
        @IBOutlet private weak var userAvatarImageView: UIImageView!
        @IBOutlet weak var userNameTopLabel: UILabel!
        @IBOutlet private weak var nameLabel: UILabel!
        @IBOutlet private weak var containerView: UIView!
        @IBOutlet weak var unmuteImageViewWidthConstraint: NSLayoutConstraint!
        @IBOutlet weak var unmuteImageView: UIImageView!
        @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
        @IBOutlet weak var videoContainerView: UIView!
        @IBOutlet weak var unmuteOnVideoImageView: UIImageView!
        
        //MARK: - Properties
        /**
         *  Change Video Gravity block action.
         */
        var didChangeVideoGravity: ((_ isResizeAspect: Bool) -> Void)?
        
        var videoView: UIView? {
            didSet {
                guard let view = videoView else {
                    return
                }
                videoContainerView.insertSubview(view, at: 0)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.leftAnchor.constraint(equalTo: videoContainerView.leftAnchor).isActive = true
                view.rightAnchor.constraint(equalTo: videoContainerView.rightAnchor).isActive = true
                view.topAnchor.constraint(equalTo: videoContainerView.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor).isActive = true
                view.layoutIfNeeded()
            }
        }
        
        var unMute = false {
            didSet {
                unmuteImageViewWidthConstraint.constant = unMute == true ? 0.0 : 40.0
                nameLabelCenterXConstraint.constant = unMute == true ? 0.0 : -10.0
                unmuteOnVideoImageView.isHidden = unMute == true
            }
        }
        
        var videoEnabled = false {
            didSet {
                videoContainerView.isHidden = !videoEnabled
            }
        }
        
        var name = "" {
            didSet {
                userNameTopLabel.text = name
                nameLabel.text = name
                userAvatarLabel.text = String(name.capitalized.first ?? Character("Q"))
            }
        }
        
        var userColor = UIColor.clear {
            didSet {
                userAvatarLabel.backgroundColor = userColor
            }
        }
        
        var isResizeAspect = true {
            didSet {
                didChangeVideoGravity?(isResizeAspect)
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
            videoContainerView.isHidden = true
            unmuteOnVideoImageView.isHidden = true
            nameLabelCenterXConstraint.constant = 0.0
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_ :)))
            videoContainerView.addGestureRecognizer(pinchGesture)
        }
    
    //MARK: - Actions
    @objc private func pinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state != .began {
            return
        }
        let currentScale = videoContainerView.frame.width / videoContainerView.bounds.width
        let newScale = currentScale * gestureRecognizer.scale
        if (isResizeAspect == true && newScale < currentScale)
            || (isResizeAspect == false && newScale > currentScale) {
            isResizeAspect = !isResizeAspect
        }
    }
}
