//
//  LocalVideoView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import AVKit

protocol LocalVideoViewDelegate: class {
    func localVideoView(_ localVideoView: LocalVideoView?, pressedSwitchButton sender: UIButton?)
}

class LocalVideoView: UIView {
    weak var delegate: LocalVideoViewDelegate?
    let image = UIImage(named: "switchCamera")
    lazy private var videoLayer: AVCaptureVideoPreviewLayer = {
        let videoLayer = AVCaptureVideoPreviewLayer()
        return videoLayer
    }()
    lazy private var switchCameraBtn: UIButton = {
        let switchCameraBtn = UIButton(type: .custom)
        switchCameraBtn.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        switchCameraBtn.setImage(image, for: .normal)
        switchCameraBtn.addTarget(self, action: #selector(didPressSwitchCamera(_:)),
                                  for: .touchUpInside)
        return switchCameraBtn
    }()
    lazy private var containerView: UIView = {
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.clear
        return containerView
    }()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(previewlayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame: CGRect.zero)
        videoLayer = layer
        videoLayer.videoGravity = .resizeAspect
        containerView.layer.insertSublayer(videoLayer, at: 0)
        insertSubview(containerView, at: 0)
        addSubview(switchCameraBtn)
        
        containerView.frame = bounds
        videoLayer.frame = bounds
        
        let buttonSize = CGSize(width: 72 / 2.5, height: 54 / 2.5)
        switchCameraBtn.frame = CGRect(x: bounds.size.width - buttonSize.width - 5,
                                       y: bounds.size.height - buttonSize.height - 30,
                                       width: buttonSize.width, height: buttonSize.height)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    @objc func didPressSwitchCamera(_ sender: UIButton?) {
        delegate?.localVideoView(self, pressedSwitchButton: sender)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.frame = bounds
        videoLayer.frame = bounds
        
        let buttonSize = CGSize(width: 72 / 2.5, height: 54 / 2.5)
        switchCameraBtn.frame = CGRect(x: bounds.size.width - buttonSize.width - 5,
                                       y: bounds.size.height - buttonSize.height - 30,
                                       width: buttonSize.width, height: buttonSize.height)
    }
    
    func updateOrientationIfNeeded() {
        
        let previewLayerConnection: AVCaptureConnection? = videoLayer.connection
        let interfaceOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue)
        
        let isVideoOrientationSupported = previewLayerConnection?.isVideoOrientationSupported
        if isVideoOrientationSupported ?? false && previewLayerConnection?.videoOrientation != videoOrientation {
            if let anOrientation = videoOrientation {
                previewLayerConnection?.videoOrientation = anOrientation
            }
        }
    }
}
