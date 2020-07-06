//
//  LocalVideoView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import AVKit

class LocalVideoView: UIView {
    //MARK: - Properties
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    private let image = UIImage(named: "switchCamera")
    
    lazy private var containerView: UIView = {
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.clear
        insertSubview(containerView, at: 0)
        return containerView
    }()
    
    //MARK: - Life Circle
    public init(previewlayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame: CGRect.zero)
        videoLayer = layer
        videoLayer?.videoGravity = .resizeAspectFill
        containerView.layer.insertSublayer(layer, at:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.frame = bounds
        videoLayer?.frame = bounds
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    //MARK: - Internal Methods
    private func updateOrientationIfNeeded() {
        let previewLayerConnection = videoLayer?.connection
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        let isVideoOrientationSupported = previewLayerConnection?.isVideoOrientationSupported
        
        guard let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue),
            isVideoOrientationSupported == true,
            previewLayerConnection?.videoOrientation != videoOrientation else {
                return
        }
        previewLayerConnection?.videoOrientation = videoOrientation
    }
}
