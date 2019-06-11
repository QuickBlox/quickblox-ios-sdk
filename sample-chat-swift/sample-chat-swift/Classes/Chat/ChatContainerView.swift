//
//  ChatContainerView.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  Customisable chat container view.
 */
class ChatContainerView: UIView {
    
    lazy var bubbleImageView: UIImageView = {
        let bubbleImageView = UIImageView()
        return bubbleImageView
    }()
    
    var image: UIImage? {
        didSet {
            bubbleImageView.image = image
        }
    }

  override func awakeFromNib() {
    super.awakeFromNib()
    
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
    insertSubview(bubbleImageView, at: 0)
    bubbleImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0).isActive = true
    bubbleImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
    bubbleImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0).isActive = true
    bubbleImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true

    isOpaque = true
  }
}
