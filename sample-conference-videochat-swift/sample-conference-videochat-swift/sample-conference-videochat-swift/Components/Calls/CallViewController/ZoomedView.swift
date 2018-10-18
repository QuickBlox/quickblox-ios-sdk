//
//  ZoomedView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ZoomedView: UIView {
    weak var videoView: UIView?
    var didTapView: ((_ zoomedView: ZoomedView?) -> Void)?

    override init(frame: CGRect) {
            
            super.init(frame: frame)
            
            backgroundColor = UIColor(white: 0, alpha: 1.0)
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didReceiveTap(_:))))
            
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        func setVideo(_ videoView: UIView?) {
            
            if self.videoView != videoView {
                self.videoView = videoView
                videoView?.removeFromSuperview()
                videoView?.frame = bounds
                videoView?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                if let aView = videoView {
                    addSubview(aView)
                }
            }
        }
        
        @objc func didReceiveTap(_ __unused: UITapGestureRecognizer?) {
            if didTapView != nil {
                didTapView!(self)
            }
        }
 

}
